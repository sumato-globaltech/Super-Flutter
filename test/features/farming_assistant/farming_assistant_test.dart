import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/hide_on_scroll.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/data/farming_assistant/model/assistant_answer_model.dart';
import 'package:super_flutter/data/farming_assistant/sources/remote/farming_assistant_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/screen/dashboard_screen.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/bloc/farming_assistant_bloc.dart';
import 'package:super_flutter/features/farming_assistant/presentation/farming_assistant/screen/farming_assistant_screen.dart';
import 'package:super_flutter/features/farming_assistant/routes/farming_assistant_routes.dart';

class _MockSource extends Mock implements FarmingAssistantRemoteDataSource {}

class _MockCommunication extends Mock
    implements CommunicationRemoteDataSource {}

class _MockLogout extends Mock implements Logout {}

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockSource source;
  final button = find.byTooltip('AI Farming Assistant');

  setUp(() async {
    source = _MockSource();
    final communication = _MockCommunication();
    when(() => communication.getBanners(placement: any(named: 'placement')))
        .thenAnswer((_) async => []);
    when(
      () => communication.getAlerts(
        districtId: any(named: 'districtId'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => const Paged(items: []));
    when(
      () => communication.getNotices(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) async => Paged(
        items: [
          for (var i = 0; i < 3; i++) NoticeModel(id: '$i', title: 'Notice $i'),
        ],
      ),
    );
    await getIt.reset();
    getIt
      ..registerSingleton<AppConfig>(AppConfig.production())
      ..registerFactory(() => FarmingAssistantBloc(source))
      ..registerFactory(() => DashboardBloc(_MockLogout(), communication));
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Size size = const Size(390, 844),
    bool dark = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => home),
            ...buildFarmingAssistantRoutes(),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget home(Set<String> permissions) {
    final auth = _MockAuth();
    when(() => auth.state).thenReturn(
      AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 'u1',
          name: 'Vizo',
          email: '',
          role: const UserRole(value: 'farmer', label: 'Farmer'),
          permissions: permissions,
          profileActive: true,
        ),
      ),
    );
    return BlocProvider<AuthCubit>.value(
      value: auth,
      child: const DashboardScreen(),
    );
  }

  bool shown(WidgetTester tester) =>
      tester
          .widget<AnimatedOpacity>(
            find.descendant(
              of: find.byType(HideOnScrollButton),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity ==
      1;

  group('Home button', () {
    testWidgets('only with the web permission, and it opens the chat', (
      tester,
    ) async {
      await pump(tester, home({}));
      expect(button, findsNothing);

      await pump(tester, home({Permissions.farmingAssistantUse}));
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Hello, I am Kheti Manu'), findsOneWidget);
    });

    testWidgets('hides on the way down and shows on the way up', (
      tester,
    ) async {
      await pump(
        tester,
        home({Permissions.farmingAssistantUse}),
        size: const Size(390, 480),
      );
      final page = find.byType(SingleChildScrollView).first;
      expect(shown(tester), isTrue);

      await tester.drag(page, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(shown(tester), isFalse);
      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(FarmingAssistantScreen), findsNothing);

      await tester.drag(page, const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(shown(tester), isTrue);
    });

    test('it is not also a quick action', () {
      expect(
        appFeatures
            .quickActions(
              const AccessPolicy(
                isSignedIn: true,
                permissions: {Permissions.farmingAssistantUse},
              ),
              home: '/',
            )
            .map((feature) => feature.id),
        isNot(contains('farming_assistant')),
      );
    });
  });

  testWidgets('sideways scrolling and short pages keep the button', (
    tester,
  ) async {
    await pump(
      tester,
      HideOnScroll(
        child: Scaffold(
          floatingActionButton: const HideOnScrollButton(child: Text('ask')),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 100,
                child: ListView(
                  key: const Key('sideways'),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < 20; i++) const SizedBox(width: 100),
                  ],
                ),
              ),
              const Text('short'),
            ],
          ),
        ),
      ),
    );
    await tester.drag(find.byKey(const Key('sideways')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(shown(tester), isTrue);
    await tester.drag(find.text('short'), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(shown(tester), isTrue);
  });

  for (final dark in [false, true]) {
    testWidgets('asks, fails, retries and answers (dark: $dark)', (
      tester,
    ) async {
      final answers = [
        Future<AssistantAnswerModel?>.error(
          const ValidationException('Try later.'),
        )..ignore(),
        Future.value(AssistantAnswerModel(answer: 'Use compost and mulch.')),
      ].iterator;
      when(() => source.createAssistantAnswer(question: 'How to grow rice?'))
          .thenAnswer((_) => (answers..moveNext()).current);
      await pump(tester, const FarmingAssistantScreen(), dark: dark);
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      verifyNever(
        () => source.createAssistantAnswer(question: any(named: 'question')),
      );

      await tester.enterText(find.byType(TextField), ' How to grow rice? ');
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();
      expect(find.text('Try later.'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('How to grow rice?'), findsOneWidget);
      expect(find.text('Use compost and mulch.'), findsOneWidget);
      expect(find.text('Try later.'), findsNothing);
    });
  }

  testWidgets('a suggestion is asked while the answer loads', (tester) async {
    final answer = Completer<AssistantAnswerModel?>();
    when(
      () => source.createAssistantAnswer(
        question: 'How to control leaf spot disease?',
      ),
    ).thenAnswer((_) => answer.future);
    await pump(tester, const FarmingAssistantScreen());
    await tester.tap(find.text('How to control leaf spot disease?'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Thinking…'), findsOneWidget);
    answer.complete(AssistantAnswerModel(answer: 'Remove infected leaves.'));
    await tester.pumpAndSettle();
    expect(find.text('Remove infected leaves.'), findsOneWidget);
  });
}
