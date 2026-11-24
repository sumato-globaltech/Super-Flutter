import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_answer_model.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_language_model.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/sources/remote/national_farming_ai_assistant_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/bloc/national_farming_ai_assistant_bloc.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/bloc/national_farming_ai_assistant_event.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/presentation/national_farming_ai_assistant/screen/national_farming_ai_assistant_screen.dart';
import 'package:super_flutter/features/national_farming_ai_assistant/routes/national_farming_ai_assistant_route_names.dart';

class _MockSource extends Mock
    implements NationalFarmingAiAssistantRemoteDataSource {}

class _MockDioClient extends Mock implements DioClient {}

class _Adapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    await requestStream?.drain<void>();
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {'answer': 'Yes'},
      }),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockSource source;
  late NationalFarmingAiAssistantBloc bloc;
  final asked = <Map<Symbol, dynamic>>[];
  var answers = <NationalFarmingAiAssistantAnswerModel? Function()>[];

  setUp(() async {
    asked.clear();
    answers = [];
    source = _MockSource();
    when(() => source.getNationalFarmingAiAssistantLanguages()).thenAnswer(
      (_) async => [
        NationalFarmingAiAssistantLanguageModel.fromJson({
          'value': 'en',
          'label': 'English',
        }),
        NationalFarmingAiAssistantLanguageModel.fromJson({
          'value': 'hi',
          'label': 'हिन्दी',
        }),
      ],
    );
    when(
      () => source.createNationalFarmingAiAssistantAnswer(
        question: any(named: 'question'),
        sessionId: any(named: 'sessionId'),
        language: any(named: 'language'),
        useLocation: any(named: 'useLocation'),
        image: any(named: 'image'),
      ),
    ).thenAnswer((call) async {
      asked.add(call.namedArguments);
      return answers.isEmpty
          ? NationalFarmingAiAssistantAnswerModel(answer: 'Use **compost**.')
          : answers.removeAt(0)();
    });
    await getIt.reset();
    getIt.registerFactory(() => bloc = NationalFarmingAiAssistantBloc(source));
  });

  Future<void> pump(WidgetTester tester, {bool dark = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NationalFarmingAiAssistantScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ask(WidgetTester tester, String question) async {
    await tester.enterText(find.byType(TextField), question);
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
  }

  test('only the web permission opens it and lists it on Home', () {
    AccessPolicy policy(Set<String> permissions) =>
        AccessPolicy(isSignedIn: true, permissions: permissions);
    bool listed(Set<String> permissions) => appFeatures
        .quickActions(policy(permissions), home: '/')
        .any((feature) => feature.id == 'national_farming_ai_assistant');

    for (final permissions in [
      <String>{},
      {Permissions.farmingAssistantUse},
    ]) {
      expect(
        appFeatures.canOpen(
          NationalFarmingAiAssistantRouteNames.root,
          policy(permissions),
        ),
        isFalse,
      );
      expect(listed(permissions), isFalse);
    }
    expect(
      appFeatures.canOpen(
        NationalFarmingAiAssistantRouteNames.root,
        policy({Permissions.nationalFarmingAiAssistantUse}),
      ),
      isTrue,
    );
    expect(listed({Permissions.nationalFarmingAiAssistantUse}), isTrue);
  });

  for (final dark in [false, true]) {
    testWidgets('asks, remembers the chat and starts a new one ($dark)', (
      tester,
    ) async {
      await pump(tester, dark: dark);
      await ask(tester, ' How to grow rice? ');
      await ask(tester, 'And maize?');
      expect(find.text('Use compost.', findRichText: true), findsNWidgets(2));
      expect(asked.first[#question], 'How to grow rice?');
      expect(asked.first[#language], 'en');
      expect(asked.first[#useLocation], isFalse);
      expect(asked.first[#image], isNull);
      expect(asked[1][#sessionId], asked[0][#sessionId]);

      await tester.tap(find.byTooltip('New chat'));
      await tester.pumpAndSettle();
      expect(
        find.text('Ask the National Farming AI Assistant'),
        findsOneWidget,
      );
      await ask(tester, 'Hello');
      expect(asked[2][#sessionId], isNot(asked[0][#sessionId]));
    });
  }

  testWidgets('the language and the place are chosen by the user', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Near me'));
    await tester.pumpAndSettle();
    await ask(tester, 'धान?');
    expect(asked.single[#language], 'hi');
    expect(asked.single[#useLocation], isTrue);

    await tester.tap(find.text('Near me'));
    await tester.pumpAndSettle();
    await ask(tester, 'धान?');
    expect(asked.last[#useLocation], isFalse);
  });

  testWidgets('a photo is asked about once, and kept for a retry', (
    tester,
  ) async {
    answers = [() => throw const ValidationException('Try later.')];
    await pump(tester);
    bloc.add(const NationalFarmingAiAssistantPhotoChosen('/leaf.jpg'));
    await tester.pumpAndSettle();
    expect(find.text('Crop photo'), findsOneWidget);
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Try later.'), findsOneWidget);
    expect(find.text('Crop photo'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Try later.'), findsNothing);
    expect(asked.map((call) => call[#image]), ['/leaf.jpg', '/leaf.jpg']);
    expect(
      asked.last[#question],
      'What disease does this plant have and how do I treat it?',
    );

    await ask(tester, 'Thanks');
    expect(asked.last[#image], isNull);
  });

  testWidgets('a photo can be taken away before sending', (tester) async {
    await pump(tester);
    bloc.add(const NationalFarmingAiAssistantPhotoChosen('/leaf.jpg'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();
    expect(find.text('Crop photo'), findsNothing);
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(asked, isEmpty);
  });

  testWidgets('an empty answer is a failure; no languages still chats', (
    tester,
  ) async {
    when(() => source.getNationalFarmingAiAssistantLanguages())
        .thenThrow(const ValidationException('no'));
    answers = [() => null];
    await pump(tester);
    expect(find.text('English'), findsNothing);
    await ask(tester, 'Hello');
    expect(find.text('Try again'), findsOneWidget);
  });

  test('it posts to dam, with the photo only when there is one', () async {
    final adapter = _Adapter();
    final client = _MockDioClient();
    when(() => client.dio).thenReturn(
      Dio(BaseOptions(baseUrl: 'http://dam.test'))..httpClientAdapter = adapter,
    );
    final source = NationalFarmingAiAssistantRemoteDataSource(client);
    final photo = File('${Directory.systemTemp.createTempSync().path}/a.jpg')
      ..writeAsBytesSync([1]);
    addTearDown(() => photo.parent.deleteSync(recursive: true));

    await source.createNationalFarmingAiAssistantAnswer(
      question: 'Q',
      sessionId: 's',
      language: 'hi',
      useLocation: true,
      image: photo.path,
    );
    expect(
      adapter.request!.uri.toString(),
      'http://dam.test/api/v1/national-farming-ai-assistant/chat',
    );
    var form = adapter.request!.data as FormData;
    expect(Map.fromEntries(form.fields), {
      'question': 'Q',
      'session_id': 's',
      'language': 'hi',
      'use_location': '1',
    });
    expect(form.files.single.key, 'image');

    final answer = await source.createNationalFarmingAiAssistantAnswer(
      question: 'Q',
      sessionId: 's',
      language: 'en',
    );
    form = adapter.request!.data as FormData;
    expect(form.files, isEmpty);
    expect(answer?.answer, 'Yes');
  });
}
