import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/access/feature_registry.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/router/app_router.dart';
import 'package:super_flutter/app/shell/app_shell_route.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/app_bottom_bar.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

AuthState signedIn(String role, Set<String> permissions) => AuthState(
  status: AuthStatus.authenticated,
  user: User(
    id: '1',
    name: 'User',
    email: 'user@example.test',
    role: UserRole(value: role, label: role),
    permissions: permissions,
    profileActive: true,
  ),
);

final farmer = signedIn(Roles.farmer, {Permissions.shipmentsRequest});
final driver = signedIn(Roles.driver, {Permissions.shipmentsDrive});

Future<GoRouter> pumpShell(
  WidgetTester tester,
  AuthCubit cubit, {
  FeatureRegistry? registry,
}) async {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      buildAppShellRoute(
        registry: registry,
        tabRoutes: {
          '/dashboard': [
            GoRoute(
              path: '/dashboard',
              builder: (_, _) => const Scaffold(body: Text('home screen')),
            ),
          ],
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: cubit,
      child: MaterialApp.router(
        theme: AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

List<String> barLabels(WidgetTester tester) => tester
    .widget<AppBottomBar>(find.byType(AppBottomBar))
    .items
    .map((i) => i.label)
    .toList();

int selectedTab(WidgetTester tester) =>
    tester.widget<AppBottomBar>(find.byType(AppBottomBar)).selectedIndex;

String _title(AppLocalizations l10n) => l10n.home;

AppFeature tab(String id, int priority) => AppFeature(
  id: id,
  path: id == 'home' ? '/dashboard' : '/$id',
  rule: const AccessRule.signedIn(),
  title: _title,
  icon: Icons.circle,
  tab: AppTab(icon: Icons.circle, activeIcon: Icons.circle, priority: priority),
);

void main() {
  late MockAuthCubit cubit;

  setUp(() => cubit = MockAuthCubit());

  testWidgets('farmer gets their five tabs and starts on home', (tester) async {
    when(() => cubit.state).thenReturn(farmer);
    await pumpShell(tester, cubit);

    expect(barLabels(tester), [
      'Home',
      'Farms',
      'Shipments',
      'Market',
      'Schemes',
    ]);
    expect(selectedTab(tester), 0);
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('driver does not see farm tabs', (tester) async {
    when(() => cubit.state).thenReturn(driver);
    await pumpShell(tester, cubit);

    expect(barLabels(tester), ['Home', 'Shipments', 'Market', 'Schemes']);
  });

  testWidgets('tapping a tab opens it and keeps home alive', (tester) async {
    when(() => cubit.state).thenReturn(farmer);
    final router = await pumpShell(tester, cubit);

    await tester.tap(find.text('Market'));
    await tester.pumpAndSettle();

    expect(selectedTab(tester), 3);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/market');

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('home screen'), findsOneWidget);
    expect(selectedTab(tester), 0);
  });

  testWidgets('tabs follow access changes live', (tester) async {
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    whenListen(cubit, states.stream, initialState: farmer);
    await pumpShell(tester, cubit);
    expect(barLabels(tester), contains('Farms'));

    when(() => cubit.state).thenReturn(driver);
    states.add(driver);
    await tester.pumpAndSettle();

    expect(barLabels(tester), ['Home', 'Shipments', 'Market', 'Schemes']);
  });

  testWidgets('more than five tabs puts the rest behind More', (tester) async {
    when(() => cubit.state).thenReturn(farmer);
    final registry = FeatureRegistry([
      tab('home', 0),
      for (var i = 1; i < 7; i++) tab('t$i', i),
    ]);
    final router = await pumpShell(tester, cubit, registry: registry);

    expect(barLabels(tester), hasLength(5));
    expect(barLabels(tester).last, 'More');

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    final sheetRows = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Home'),
    );
    expect(sheetRows, findsNWidgets(3));

    await tester.tap(sheetRows.last);
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/t6');
    expect(selectedTab(tester), 4);
  });

  testWidgets('back on another tab returns to home first', (tester) async {
    when(() => cubit.state).thenReturn(farmer);
    final router = await pumpShell(tester, cubit);

    await tester.tap(find.text('Schemes'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/dashboard');
    expect(find.text('home screen'), findsOneWidget);
  });

  testWidgets('a single destination shows no bottom bar', (tester) async {
    when(() => cubit.state).thenReturn(farmer);
    await pumpShell(tester, cubit, registry: FeatureRegistry([tab('home', 0)]));

    expect(find.byType(AppBottomBar), findsNothing);
    expect(find.text('home screen'), findsOneWidget);
  });
}
