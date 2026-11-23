import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/features/communication/presentation/alerts/bloc/alerts_bloc.dart';
import 'package:super_flutter/features/communication/presentation/alerts/screen/alerts_screen.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/bloc/notice_detail_bloc.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/screen/notice_detail_screen.dart';
import 'package:super_flutter/features/communication/presentation/notices/bloc/notices_bloc.dart';
import 'package:super_flutter/features/communication/presentation/notices/screen/notices_screen.dart';
import 'package:super_flutter/features/communication/routes/communication_route_names.dart';

class _Source extends Mock implements CommunicationRemoteDataSource {}

final _notice = NoticeModel(
  id: 'n1',
  title: 'Crop insurance enrolment open',
  body: 'All eligible farmers can enrol for the Pradhan Mantri Fasal Bima Yojana. Last date: 30 Jun 2026.',
  category: CategoryModel(id: 'c2', name: 'Schemes'),
  priority: PriorityModel(value: 'high', label: 'High'),
  publishedAt: DateTime(2026, 6, 10),
  expiresAt: DateTime(2026, 6, 30),
);

final _noticesPage = Paged(
  items: [
    _notice,
    NoticeModel(
      id: 'n2',
      title: 'Soil testing camp at Jorhat',
      category: CategoryModel(id: 'c3', name: 'Events'),
      priority: PriorityModel(value: 'normal', label: 'Normal'),
      publishedAt: DateTime(2026, 6, 8),
    ),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 2,
);

final _alertsPage = Paged(
  items: [
    AlertModel(
      id: 'a1',
      title: 'Heavy rainfall',
      description: 'Heavy rainfall expected in Jorhat over the next 48 hours.',
      severity: SeverityModel(value: 'emergency', label: 'Emergency'),
      district: DistrictModel(id: 'd1', name: 'Jorhat'),
      category: CategoryModel(id: 'c1', name: 'Weather'),
      statewide: false,
    ),
    AlertModel(
      id: 'a2',
      title: 'Pest watch across the state',
      severity: SeverityModel(value: 'watch', label: 'Watch'),
      statewide: true,
    ),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 2,
);

void main() {
  late _Source source;

  setUp(() async {
    source = _Source();
    await getIt.reset();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    bool dark = true,
    String initialRoute = '/',
    List<GoRoute>? routes,
  }) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: initialRoute,
      routes: routes ?? [
        GoRoute(
          path: '/',
          builder: (_, _) => home,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  // ─── Notice detail ───

  group('notice detail', () {
    testWidgets('shows notice fields and body', (tester) async {
      when(() => source.getNotice(any())).thenAnswer((_) async => _notice);
      getIt.registerFactory<NoticeDetailBloc>(() => NoticeDetailBloc(source));
      await pump(
        tester,
        const NoticeDetailScreen(noticeId: 'n1'),
        dark: true,
      );

      expect(find.text('Notice'), findsOneWidget); // AppBar title
      expect(find.text('Crop insurance enrolment open'), findsOneWidget);
      expect(find.text('Schemes'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Jun 10, 2026'), findsOneWidget);
      expect(find.text('Jun 30, 2026'), findsOneWidget);
      // Body rendered as selectable text.
      expect(
        find.text(
          'All eligible farmers can enrol for the Pradhan Mantri Fasal Bima Yojana. Last date: 30 Jun 2026.',
        ),
        findsOneWidget,
      );
      verify(() => source.getNotice('n1')).called(1);
    });

    testWidgets('error shows retry', (tester) async {
      when(() => source.getNotice(any())).thenThrow(
        const UnknownException('Offline'),
      );
      getIt.registerFactory<NoticeDetailBloc>(() => NoticeDetailBloc(source));
      await pump(
        tester,
        const NoticeDetailScreen(noticeId: 'n1'),
        dark: true,
      );

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);

      when(() => source.getNotice(any())).thenAnswer((_) async => _notice);
      tester.widget<AppErrorView>(find.byType(AppErrorView)).onRetry!();
      await tester.pumpAndSettle();
      expect(find.text('Crop insurance enrolment open'), findsOneWidget);
    });
  });

  // ─── Notices list ───

  group('notices list', () {
    testWidgets('shows notice cards and taps to detail', (tester) async {
      when(
        () => source.getNotices(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _noticesPage);
      when(() => source.getNotice(any())).thenAnswer((_) async => _notice);
      getIt
        ..registerFactory<NoticesBloc>(() => NoticesBloc(source))
        ..registerFactory<NoticeDetailBloc>(() => NoticeDetailBloc(source));
      await pump(
        tester,
        const SizedBox.shrink(),
        initialRoute: CommunicationRouteNames.notices,
        routes: [
          GoRoute(
            path: CommunicationRouteNames.notices,
            builder: (_, _) => const NoticesScreen(),
            routes: [
              GoRoute(
                path: ':noticeId',
                builder: (_, state) => NoticeDetailScreen(
                  noticeId: state.pathParameters['noticeId']!,
                ),
              ),
            ],
          ),
        ],
      );

      expect(find.text('Notices'), findsOneWidget); // AppBar
      expect(find.text('Crop insurance enrolment open'), findsOneWidget);
      expect(find.text('Soil testing camp at Jorhat'), findsOneWidget);
      expect(find.text('Schemes · Jun 10, 2026'), findsOneWidget);

      // Tap on a notice to open its detail.
      await tester.tap(find.text('Crop insurance enrolment open'));
      await tester.pumpAndSettle();
      expect(find.text('Jun 30, 2026'), findsOneWidget); // detail field
    });

    testWidgets('empty shows empty view', (tester) async {
      when(
        () => source.getNotices(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => const Paged(items: <NoticeModel>[]));
      getIt.registerFactory<NoticesBloc>(() => NoticesBloc(source));
      await pump(tester, const NoticesScreen());

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No notices yet'), findsOneWidget);
    });

    testWidgets('error shows error view', (tester) async {
      when(
        () => source.getNotices(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenThrow(const UnknownException('Offline'));
      getIt.registerFactory<NoticesBloc>(() => NoticesBloc(source));
      await pump(tester, const NoticesScreen());

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });
  });

  // ─── Alerts list ───

  group('alerts list', () {
    testWidgets('shows alert cards with severity accents', (tester) async {
      when(
        () => source.getAlerts(
          districtId: any(named: 'districtId'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _alertsPage);
      getIt.registerFactory<AlertsBloc>(() => AlertsBloc(source));
      await pump(tester, const AlertsScreen(), dark: true);

      expect(find.text('Alerts'), findsOneWidget); // AppBar
      expect(find.text('Heavy rainfall'), findsOneWidget);
      expect(find.text('Emergency · Jorhat'), findsOneWidget);
      expect(find.text('Watch · Statewide'), findsOneWidget);
      expect(find.text('Pest watch across the state'), findsOneWidget);

      // Description is read-more.
      final cards = tester
          .widgetList<TitleDetailsCard>(find.byType(TitleDetailsCard))
          .toList();
      final descCard = cards.firstWhere(
        (c) => c.text?.startsWith('Heavy rainfall expected') ?? false,
      );
      expect(descCard.isReadMore, isTrue);
    });

    testWidgets('empty shows empty view', (tester) async {
      when(
        () => source.getAlerts(
          districtId: any(named: 'districtId'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => const Paged(items: <AlertModel>[]));
      getIt.registerFactory<AlertsBloc>(() => AlertsBloc(source));
      await pump(tester, const AlertsScreen());

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No alerts'), findsOneWidget);
    });

    testWidgets('error shows error view', (tester) async {
      when(
        () => source.getAlerts(
          districtId: any(named: 'districtId'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenThrow(const UnknownException('Offline'));
      getIt.registerFactory<AlertsBloc>(() => AlertsBloc(source));
      await pump(tester, const AlertsScreen());

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
    });
  });
}
