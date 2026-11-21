import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/app/access/feature_registry.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';

String _title(AppLocalizations l10n) => l10n.home;

AppFeature feature(
  String id, {
  String? path,
  int? priority,
  AccessRule rule = const AccessRule.public(),
}) => AppFeature(
  id: id,
  path: path ?? '/$id',
  rule: rule,
  title: _title,
  icon: Icons.circle,
  tab: priority == null
      ? null
      : AppTab(
          icon: Icons.circle,
          activeIcon: Icons.circle,
          priority: priority,
        ),
);

const _user = AccessPolicy(isSignedIn: true);

void main() {
  test('orders tabs by priority, keeping list order for ties', () {
    final registry = FeatureRegistry([
      feature('c', priority: 20),
      feature('a', priority: 10),
      feature('b', priority: 10),
      feature('hidden'),
    ]);

    expect(registry.navigationFor(_user).tabs.map((f) => f.id), [
      'a',
      'b',
      'c',
    ]);
  });

  test('more than five tabs puts the rest behind More', () {
    final registry = FeatureRegistry([
      for (var i = 0; i < 7; i++) feature('t$i', priority: i),
    ]);

    final layout = registry.navigationFor(_user);

    expect(layout.tabs.map((f) => f.id), ['t0', 't1', 't2', 't3']);
    expect(layout.overflow.map((f) => f.id), ['t4', 't5', 't6']);
    expect(layout.hasMore, isTrue);
  });

  test('exactly five tabs need no More', () {
    final registry = FeatureRegistry([
      for (var i = 0; i < 5; i++) feature('t$i', priority: i),
    ]);

    final layout = registry.navigationFor(_user);

    expect(layout.tabs, hasLength(5));
    expect(layout.hasMore, isFalse);
  });

  test('two features on one path give one tab', () {
    final registry = FeatureRegistry([
      feature('first', path: '/shared', priority: 1),
      feature('second', path: '/shared', priority: 1),
    ]);

    expect(registry.navigationFor(_user).tabs.map((f) => f.id), ['first']);
  });

  test('denied features are left out everywhere', () {
    final registry = FeatureRegistry([
      feature(
        'admin',
        priority: 1,
        rule: const AccessRule.permission('users.view'),
      ),
      feature('open', priority: 2),
      feature('menu', rule: const AccessRule.permission('users.view')),
    ]);

    expect(registry.navigationFor(_user).tabs.map((f) => f.id), ['open']);
    expect(registry.secondary(_user), isEmpty);
    expect(registry.canOpen('/admin', _user), isFalse);
  });

  test('the most specific path decides', () {
    final registry = FeatureRegistry([
      feature('notices', path: '/notices'),
      feature(
        'manage',
        path: '/notices/manage',
        rule: const AccessRule.permission('notices.manage'),
      ),
    ]);

    expect(registry.canOpen('/notices/01ABC', _user), isTrue);
    expect(registry.canOpen('/notices/manage/new', _user), isFalse);
    expect(registry.canOpen('/noticesboard', _user), isTrue);
  });

  test('feature ids must be unique', () {
    expect(
      () => FeatureRegistry([feature('a'), feature('a', path: '/b')]),
      throwsAssertionError,
    );
  });
}
