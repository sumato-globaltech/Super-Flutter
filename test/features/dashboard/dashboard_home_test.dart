import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/theme/design_colors.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/banner_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/screen/dashboard_screen.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _Logout extends Mock implements Logout {}

class _Source extends Mock implements CommunicationRemoteDataSource {}

class _Launcher extends UrlLauncherPlatform {
  final launched = <String>[];
  @override
  LinkDelegate? get linkDelegate => null;
  @override
  Future<bool> canLaunch(String url) async => true;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}

final _banners = [
  BannerModel(
    id: 'b1',
    title: 'Kharif seed subsidy',
    linkUrl: 'https://agri.assam.gov.in/schemes',
  ),
  BannerModel(id: 'b2', title: 'Soil health card camp'),
];
final _alerts = [
  AlertModel(
    id: 'a1',
    title: 'Heavy rainfall',
    description: 'Heavy rainfall expected in Jorhat over the next 48 hours. Secure livestock and crops.',
    severity: SeverityModel(value: 'emergency', label: 'Emergency'),
    district: DistrictModel(id: 'd1', name: 'Jorhat'),
    category: CategoryModel(id: 'c1', name: 'Weather'),
    statewide: false,
  ),
  AlertModel(
    id: 'a2',
    title: 'Pest watch',
    severity: SeverityModel(value: 'watch', label: 'Watch'),
    statewide: true,
  ),
];
final _notices = [
  NoticeModel(
    id: 'n1',
    title: 'Crop insurance enrolment open',
    category: CategoryModel(id: 'c2', name: 'Schemes'),
    priority: PriorityModel(value: 'high', label: 'High'),
    publishedAt: DateTime(2026, 6, 10),
  ),
];

void main() {
  late _Source source;

  void answer({bool content = true, bool fail = false}) {
    Future<T> result<T>(T value) => fail
        ? Future.error(const UnknownException('Offline'))
        : Future.value(value);
    when(() => source.getBanners(placement: any(named: 'placement')))
        .thenAnswer((_) => result(content ? _banners : []));
    when(
      () => source.getAlerts(
        districtId: any(named: 'districtId'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) => result(Paged(items: content ? _alerts : <AlertModel>[])),
    );
    when(
      () => source.getNotices(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) => result(Paged(items: content ? _notices : <NoticeModel>[])),
    );
  }

  setUp(() async {
    source = _Source();
    await getIt.reset();
    getIt
      ..registerSingleton<AppConfig>(AppConfig.production())
      ..registerFactory<DashboardBloc>(() => DashboardBloc(_Logout(), source));
  });

  Future<void> pump(WidgetTester tester, {bool dark = true}) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [true, false]) {
    testWidgets(
      'banners, alerts by severity and notices (${dark ? 'dark' : 'light'})',
      (tester) async {
        final launcher = _Launcher();
        UrlLauncherPlatform.instance = launcher;
        answer();
        await pump(tester, dark: dark);

        expect(find.text('Kharif seed subsidy'), findsOneWidget);
        expect(find.text('Alerts today'), findsOneWidget);
        expect(find.text('Emergency · Jorhat'), findsOneWidget);
        expect(find.text('Watch · Statewide'), findsOneWidget);
        expect(find.text('Latest notices'), findsOneWidget);
        expect(find.text('Crop insurance enrolment open'), findsOneWidget);
        expect(find.text('Schemes · Jun 10, 2026'), findsOneWidget);

        final cards = tester
            .widgetList<TitleDetailsCard>(find.byType(TitleDetailsCard))
            .toList();
        final emergency = cards.firstWhere((c) => c.text == 'Heavy rainfall');
        final theme = Theme.of(tester.element(find.byType(DashboardScreen)));
        expect(emergency.accentColor, theme.colorScheme.error);
        expect(
          cards.firstWhere((c) => c.text == 'Pest watch').accentColor,
          DesignColor.golden,
        );
        expect(
          cards
              .firstWhere(
                (c) => c.text?.startsWith('Heavy rainfall expected') ?? false,
              )
              .isReadMore,
          isTrue,
        );

        // The carousel's own overlay takes the tap, over the item.
        await tester.tap(find.text('Kharif seed subsidy'), warnIfMissed: false);
        await tester.pump();
        expect(launcher.launched, ['https://agri.assam.gov.in/schemes']);
        // A banner without a link does nothing.
        await tester.drag(
          find.text('Kharif seed subsidy'),
          const Offset(-300, 0),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text('Soil health card camp'),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(launcher.launched, hasLength(1));
      },
    );
  }

  testWidgets('nothing today says so and can be pulled', (tester) async {
    answer(content: false);
    await pump(tester);
    expect(find.text('Nothing new today'), findsOneWidget);
    expect(find.text('Alerts today'), findsNothing);

    answer();
    await tester.fling(
      find.text('Nothing new today'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Heavy rainfall'), findsOneWidget);
  });

  testWidgets('nothing loading offers to retry', (tester) async {
    answer(fail: true);
    await pump(tester);
    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);

    answer();
    tester.widget<AppErrorView>(find.byType(AppErrorView)).onRetry!();
    await tester.pumpAndSettle();
    expect(find.text('Heavy rainfall'), findsOneWidget);
  });
}
