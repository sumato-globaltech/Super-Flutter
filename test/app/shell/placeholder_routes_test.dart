import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/app/access/feature_registry.dart';
import 'package:super_flutter/app/shell/placeholder_routes.dart';
import 'package:super_flutter/app/shell/tab_placeholder_screen.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';

String _title(AppLocalizations l10n) => l10n.crops;

AppFeature _feature(String id, String path, {AppTab? tab}) => AppFeature(
  id: id,
  path: path,
  rule: const AccessRule.public(),
  title: _title,
  icon: PhosphorIconsRegular.plant,
  tab: tab,
);

void main() {
  final registry = FeatureRegistry([
    _feature(
      'home',
      '/home',
      tab: const AppTab(
        icon: PhosphorIconsRegular.house,
        activeIcon: PhosphorIconsFill.house,
      ),
    ),
    _feature('crops', '/crops'),
    _feature('built', '/built'),
    _feature('nested', '/built/inside'),
  ]);

  test('features off the tabs without routes get a placeholder', () {
    final routes = withPlaceholderRoutes(registry, [
      GoRoute(
        path: '/built',
        builder: (_, _) => const SizedBox(),
        routes: [GoRoute(path: 'inside', builder: (_, _) => const SizedBox())],
      ),
    ]);
    final paths = routes.whereType<GoRoute>().map((r) => r.path).toList();
    expect(paths, ['/built', '/crops']);
  });

  testWidgets('opening one shows coming soon with a way back', (tester) async {
    final router = GoRouter(
      routes: withPlaceholderRoutes(registry, [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => context.push('/crops'),
            child: const Text('open'),
          ),
        ),
      ]),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(TabPlaceholderScreen), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
