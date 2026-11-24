import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/router/navigator_keys.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/data/admin_communication/model/admin_alert_model.dart';
import 'package:super_flutter/data/admin_communication/model/admin_notice_model.dart';
import 'package:super_flutter/data/admin_communication/model/district_model.dart'
    as options;
import 'package:super_flutter/data/admin_communication/model/priority_model.dart'
    as options;
import 'package:super_flutter/data/admin_communication/model/severity_model.dart'
    as options;
import 'package:super_flutter/data/admin_communication/sources/remote/admin_communication_remote_data_source.dart';
import 'package:super_flutter/data/support/model/category_model.dart'
    as options;
import 'package:super_flutter/features/admin_communication/presentation/add_notice/bloc/add_notice_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_alerts/bloc/admin_alerts_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/admin_notices/bloc/admin_notices_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_alert/bloc/edit_alert_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/edit_notice/bloc/edit_notice_bloc.dart';
import 'package:super_flutter/features/admin_communication/presentation/notice_body.dart';
import 'package:super_flutter/features/admin_communication/routes/admin_communication_route_names.dart';
import 'package:super_flutter/features/admin_communication/routes/admin_communication_routes.dart';

class _MockSource extends Mock implements AdminCommunicationRemoteDataSource {}

void main() {
  late _MockSource source;
  const html = '<p>Collect <strong>seed</strong></p>';

  AdminNoticeModel notice(String status) => AdminNoticeModel.fromJson({
    'id': 'n1',
    'title': 'Seed dates',
    'category': {'id': 'gone', 'name': 'Old category'},
    'priority': {'value': 'high', 'label': 'High'},
    'expires_at': '2026-12-31T23:59:59+05:30',
    'body': html,
    'status': {'value': status, 'label': status},
  });
  AdminAlertModel alert(String status) => AdminAlertModel.fromJson({
    'id': 'a1',
    'title': 'Flood',
    'description': 'River rising',
    'category': {'id': 'c1', 'name': 'Weather'},
    'district': {'id': 'd1', 'name': 'Kohima'},
    'statewide': false,
    'severity': {'value': 'watch', 'label': 'Watch'},
    'starts_on': '2026-11-05',
    'ends_on': '2026-11-07',
    'status': {'value': status, 'label': status},
  });

  setUp(() async {
    source = _MockSource();
    registerFallbackValue(DateTime(2026));
    await getIt.reset();
    getIt
      ..registerFactory(() => AdminNoticesBloc(source))
      ..registerFactory(() => AdminAlertsBloc(source))
      ..registerFactory(() => AddNoticeBloc(source))
      ..registerFactory(() => EditNoticeBloc(source))
      ..registerFactory(() => EditAlertBloc(source));
    final category = options.CategoryModel(id: 'c1', name: 'Weather');
    when(() => source.getNoticeType()).thenAnswer((_) async => [category]);
    when(() => source.getAlertType()).thenAnswer((_) async => [category]);
    when(() => source.getPriorities()).thenAnswer(
      (_) async => [options.PriorityModel(id: 'high', name: 'High')],
    );
    when(() => source.getSeverities()).thenAnswer(
      (_) async => [options.SeverityModel(id: 'watch', name: 'Watch')],
    );
    when(() => source.getDistricts()).thenAnswer(
      (_) async => [options.DistrictModel(id: 'd1', name: 'Kohima')],
    );
  });

  void notices(String status) => when(
    () => source.getAdminNotices(page: 1, perPage: any(named: 'perPage')),
  ).thenAnswer((_) async => Paged(items: [notice(status)]));

  Future<void> pump(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          navigatorKey: rootNavigatorKey,
          initialLocation: location,
          routes: buildAdminCommunicationRoutes(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('notice body', () {
    test('text and html convert both ways, escaping markup', () {
      expect(
        noticeBodyToHtml('One & two\nthree\n\n<b>four</b>'),
        '<p>One &amp; two<br>three</p><p>&lt;b&gt;four&lt;/b&gt;</p>',
      );
      expect(noticeBodyToHtml('  '), isNull);
      const text = 'One & two\nthree\n\n<b>four</b> &lt;';
      expect(noticeBodyToText(noticeBodyToHtml(text)), text);
      expect(
        noticeBodyToText('<h2>Head</h2><ul><li>a</li><li>b&#039;s</li></ul>'),
        "Head\n\n• a\n• b's",
      );
      expect(noticeBodyHasFormatting(html), isTrue);
      expect(noticeBodyHasFormatting('<p>plain</p>'), isFalse);
    });
  });

  testWidgets('a draft can be published, and a refusal stays in the sheet', (
    tester,
  ) async {
    notices('draft');
    when(() => source.publishNotice('n1')).thenAnswer(
      (_) async => throw const ValidationException(
        'Complete the notice before publishing it.',
      ),
    );
    await pump(tester, AdminCommunicationRouteNames.root);
    expect(find.text('Seed dates'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);

    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmSheet),
        matching: find.byType(ElevatedButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Complete the notice before publishing it.'),
      findsOneWidget,
    );

    when(() => source.publishNotice('n1')).thenAnswer((_) async => true);
    notices('published');
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmSheet),
        matching: find.byType(ElevatedButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmSheet), findsNothing);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('editing keeps formatting, an old category, and clears a date', (
    tester,
  ) async {
    notices('draft');
    when(
      () => source.updateEditNotice(
        'n1',
        categoryId: any(named: 'categoryId'),
        title: any(named: 'title'),
        bodyHtml: any(named: 'bodyHtml'),
        priority: any(named: 'priority'),
        expiresOn: any(named: 'expiresOn'),
      ),
    ).thenAnswer((_) async => true);
    await pump(tester, AdminCommunicationRouteNames.root);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Collect seed'), findsOneWidget);
    expect(find.text('Old category'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('31 Dec 2026'), findsOneWidget);
    expect(find.text('Title *'), findsOneWidget);
    expect(find.textContaining('has formatting'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    verify(
      () => source.updateEditNotice(
        'n1',
        categoryId: 'gone',
        title: 'Seed dates',
        bodyHtml: html,
        priority: 'high',
      ),
    ).called(1);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('an alert can go from a district to statewide', (tester) async {
    when(() => source.getAdminAlerts(page: 1, perPage: any(named: 'perPage')))
        .thenAnswer((_) async => Paged(items: [alert('active')]));
    when(
      () => source.updateEditAlert(
        'a1',
        categoryId: any(named: 'categoryId'),
        districtId: any(named: 'districtId'),
        title: any(named: 'title'),
        description: any(named: 'description'),
        severity: any(named: 'severity'),
        startsOn: any(named: 'startsOn'),
        endsOn: any(named: 'endsOn'),
      ),
    ).thenAnswer((_) async => true);
    await pump(tester, AdminCommunicationRouteNames.adminAlerts);
    expect(find.text('active · Watch · Kohima'), findsOneWidget);
    expect(find.text('Cancel alert'), findsOneWidget);
    expect(find.text('Activate'), findsNothing);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kohima'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Statewide').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    verify(
      () => source.updateEditAlert(
        'a1',
        categoryId: 'c1',
        title: 'Flood',
        description: 'River rising',
        severity: 'watch',
        startsOn: DateTime(2026, 11, 5),
        endsOn: DateTime(2026, 11, 7),
      ),
    ).called(1);
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('an edit link without its notice opens the list', (tester) async {
    notices('archived');
    await pump(tester, AdminCommunicationRouteNames.editNoticeFor('n1'));
    expect(find.text('Manage Notices'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
  });
}
