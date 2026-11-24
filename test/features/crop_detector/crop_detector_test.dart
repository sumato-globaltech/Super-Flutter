import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/data/crop_detector/model/crop_analysis_model.dart';
import 'package:super_flutter/data/crop_detector/sources/remote/crop_detector_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_bloc.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_event.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/bloc/crop_detector_state.dart';
import 'package:super_flutter/features/crop_detector/presentation/crop_detector/screen/crop_detector_screen.dart';
import 'package:super_flutter/features/crop_detector/routes/crop_detector_route_names.dart';

class _MockSource extends Mock implements CropDetectorRemoteDataSource {}

void main() {
  late _MockSource source;
  late CropDetectorBloc bloc;
  final analysis = CropAnalysisModel.fromJson({
    'crop_health': 'diseased',
    'crops': ['RICE'],
    'focus': 'ok',
    'distance': 'too_far',
    'notice': null,
    'diagnoses': [
      {
        'name': 'Blast',
        'scientific_name': 'Magnaporthe oryzae',
        'likelihood': 'very_likely',
        'images': <String>[],
        'signs': ['Grey spots'],
        'description': 'Spots on leaves',
        'prevention': ['Rotate crops', 'Use clean seed'],
        'organic_treatment': null,
        'chemical_treatment': 'Ask an officer',
      },
    ],
  });

  setUp(() async {
    source = _MockSource();
    await getIt.reset();
    getIt.registerFactory(() => bloc = CropDetectorBloc(source));
  });

  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(390, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CropDetectorScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('only users with the web permission can open it', () {
    bool open(Set<String> permissions) => appFeatures.canOpen(
      CropDetectorRouteNames.root,
      AccessPolicy(
        isSignedIn: true,
        role: Roles.farmer,
        permissions: permissions,
        profileActive: true,
      ),
    );
    expect(open({'crop_detector.use'}), isTrue);
    expect(open({'shipments.request'}), isFalse);
    expect(
      appFeatures.canOpen(CropDetectorRouteNames.root, AccessPolicy.guest),
      isFalse,
    );
    expect(
      appFeatures
          .quickActions(
            const AccessPolicy(
              isSignedIn: true,
              permissions: {'crop_detector.use'},
            ),
            home: '/',
          )
          .map((feature) => feature.id),
      contains('crop_detector'),
    );
  });

  test('a second photo is ignored while one is being checked', () async {
    bloc = CropDetectorBloc(source);
    final answer = Completer<CropAnalysisModel?>();
    when(() => source.createCropAnalysis(image: 'a.jpg', fromGallery: true))
        .thenAnswer((_) => answer.future);
    bloc
      ..add(const CropPhotoChosen(path: 'a.jpg', fromGallery: true))
      ..add(const CropPhotoChosen(path: 'b.jpg', fromGallery: true));
    await Future<void>.delayed(Duration.zero);
    answer.complete(analysis);
    await bloc.stream.firstWhere((s) => s.status == CropDetectorStatus.success);
    verifyNever(
      () => source.createCropAnalysis(image: 'b.jpg', fromGallery: true),
    );
    await bloc.close();
  });

  for (final dark in [false, true]) {
    testWidgets('shows guide, then the result (dark: $dark)', (tester) async {
      when(() => source.createCropAnalysis(image: 'a.jpg', fromGallery: false))
          .thenAnswer((_) async => analysis);
      await pump(tester, dark: dark);
      expect(find.textContaining('sent to Plantix'), findsOneWidget);

      bloc.add(const CropPhotoChosen(path: 'a.jpg', fromGallery: false));
      await tester.pumpAndSettle();
      for (final text in [
        'Diseased',
        'Rice',
        'Focus: Ok · Distance: Too far',
        'Very likely · Magnaporthe oryzae',
        'Grey spots',
        'Scan again',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.textContaining('• Use clean seed'), findsOneWidget);
      expect(find.text('Organic treatment'), findsNothing);
    });
  }

  testWidgets('a refusal shows and the same photo can be retried', (
    tester,
  ) async {
    when(
      () => source.createCropAnalysis(image: 'a.jpg', fromGallery: false),
    ).thenAnswer((_) async => throw const ValidationException('Not allowed.'));
    await pump(tester);
    bloc.add(const CropPhotoChosen(path: 'a.jpg', fromGallery: false));
    await tester.pumpAndSettle();
    expect(find.text('Not allowed.'), findsOneWidget);

    when(() => source.createCropAnalysis(image: 'a.jpg', fromGallery: false))
        .thenAnswer((_) async => analysis);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Blast'), findsOneWidget);
  });
}
