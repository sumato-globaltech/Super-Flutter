import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/data/production/model/production_insights_model.dart';
import 'package:super_flutter/data/production/sources/remote/production_remote_data_source.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_bloc.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_event.dart';
import 'package:super_flutter/features/production/presentation/production/bloc/production_state.dart';
import 'package:super_flutter/features/production/presentation/production/screen/production_screen.dart';

class _MockProduction extends Mock implements ProductionRemoteDataSource {}

class _MockCrops extends Mock implements CropRemoteDataSource {}

void main() {
  late _MockProduction source;
  late _MockCrops crops;
  const names = [
    'April', 'May', 'June', 'July', 'August', 'September', //
    'October', 'November', 'December', 'January', 'February', 'March',
  ];
  final insights = ProductionInsightsModel(
    financialYear: '2026-27',
    totalTonnes: '123456.050',
    byCrop: [
      ByCropModel(crop: 'Rice', records: 3, districts: 1, tonnes: '106.550'),
    ],
    byMonth: [
      for (final (i, name) in names.indexed)
        ByMonthModel(
          month: (i + 3) % 12 + 1,
          name: name,
          tonnes: i == 5 ? '0.000' : '${(i + 1) * 1234}.500',
        ),
    ],
  );

  setUp(() async {
    source = _MockProduction();
    crops = _MockCrops();
    await getIt.reset();
    getIt.registerFactory(() => ProductionBloc(source, crops));
    when(() => source.getProduction()).thenAnswer((_) async => insights);
    when(() => crops.getCrops(perPage: 100)).thenAnswer(
      (_) async => const Paged(
        items: [CropModel(id: 'c1', name: 'Rice', slug: 'rice')],
      ),
    );
  });

  test('filters are sent; a refused one keeps what is on screen', () async {
    when(() => source.getProduction(month: 7, crop: 'rice'))
        .thenAnswer((_) async => insights);
    when(
      () => source.getProduction(month: 8, crop: 'rice'),
    ).thenAnswer((_) async => throw const ValidationException('Not allowed.'));
    final bloc = ProductionBloc(source, crops);
    Future<ProductionState> load(ProductionFilter filter) async {
      bloc.add(ProductionStarted(filter: filter));
      await bloc.stream.firstWhere((s) => s.status == ProductionStatus.loading);
      return bloc.stream.firstWhere(
        (s) => s.status != ProductionStatus.loading,
      );
    }

    var state = await load((month: 7, crop: 'rice'));
    expect(state.status, ProductionStatus.success);
    expect(state.filter, (month: 7, crop: 'rice'));

    state = await load((month: 8, crop: 'rice'));
    expect(state.status, ProductionStatus.failure);
    expect(state.errorMessage, 'Not allowed.');
    expect(state.filter, (month: 7, crop: 'rice'));
    await bloc.close();
  });

  test('insights load even when the crop list fails', () async {
    when(() => crops.getCrops(perPage: 100))
        .thenAnswer((_) async => throw Exception());
    final bloc = ProductionBloc(source, crops)..add(const ProductionStarted());
    final state = await bloc.stream.firstWhere(
      (s) => s.status == ProductionStatus.success,
    );
    expect(state.productionInsights, insights);
    await bloc.close();
  });

  Future<void> pump(WidgetTester tester, ThemeData theme) async {
    tester.view.physicalSize = const Size(390, 1250);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductionScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [
    ('light', AppTheme.light(Flavor.development)),
    ('dark', AppTheme.dark(Flavor.development)),
  ]) {
    testWidgets('shows totals, months and crops ($name)', (tester) async {
      await pump(tester, theme);
      expect(find.text('123,456.05'), findsOneWidget);
      expect(find.text('September'), findsOneWidget);
      expect(
        find.text('106.55 tonnes · 3 records · 1 district'),
        findsOneWidget,
      );
    });
  }

  testWidgets('picking a month asks for it', (tester) async {
    when(() => source.getProduction(month: 7))
        .thenAnswer((_) async => insights);
    await pump(tester, AppTheme.light(Flavor.development));
    await tester.tap(find.text('All months'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('July').last);
    await tester.pumpAndSettle();
    verify(() => source.getProduction(month: 7)).called(1);
  });
}
