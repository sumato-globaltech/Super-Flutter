import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';

class AppTab {
  const AppTab({
    required this.icon,
    required this.activeIcon,
    this.priority = 50,
  });
  final IconData icon;
  final IconData activeIcon;
  final int priority;
}

class AppFeature {
  const AppFeature({
    required this.id,
    required this.path,
    required this.rule,
    required this.title,
    required this.icon,
    this.tab,
  });

  final String id;
  final String path;
  final AccessRule rule;
  final String Function(AppLocalizations l10n) title;
  final IconData icon;

  final AppTab? tab;

  bool allowedFor(AccessPolicy policy) => rule.allows(policy);

  @override
  String toString() => 'AppFeature($id)';
}

class NavigationLayout {
  const NavigationLayout({required this.tabs, this.overflow = const []});

  final List<AppFeature> tabs;

  final List<AppFeature> overflow;

  bool get hasMore => overflow.isNotEmpty;
}

class FeatureRegistry {
  FeatureRegistry(this.features)
    : assert(
        features.map((f) => f.id).toSet().length == features.length,
        'Feature ids must be unique.',
      );

  final List<AppFeature> features;

  List<String> get tabPaths => [
    ...{
      for (final f in features)
        if (f.tab != null) f.path,
    },
  ];

  AppFeature? featureAt(String path) {
    for (final f in features) {
      if (f.path == path) return f;
    }
    return null;
  }

  List<AppFeature> allowed(AccessPolicy policy) =>
      features.where((f) => f.allowedFor(policy)).toList(growable: false);

  NavigationLayout navigationFor(AccessPolicy policy, {int maxTabs = 5}) {
    assert(maxTabs >= 2);
    final indexed = allowed(policy).indexed
        .where((entry) => entry.$2.tab != null)
        .toList();
    indexed.sort((a, b) {
      final byPriority = a.$2.tab!.priority.compareTo(b.$2.tab!.priority);
      return byPriority != 0 ? byPriority : a.$1.compareTo(b.$1);
    });
    final seenPaths = <String>{};
    final tabs = [
      for (final (_, feature) in indexed)
        if (seenPaths.add(feature.path)) feature,
    ];
    if (tabs.length <= maxTabs) return NavigationLayout(tabs: tabs);
    return NavigationLayout(
      tabs: tabs.take(maxTabs - 1).toList(growable: false),
      overflow: tabs.skip(maxTabs - 1).toList(growable: false),
    );
  }

  /// What the user can open that the tab bar does not show: tabs past
  /// [maxTabs], then the features without one. [home] is left out.
  List<AppFeature> quickActions(
    AccessPolicy policy, {
    required String home,
    int maxTabs = 5,
  }) {
    final paths = <String>{home};
    return [
      for (final feature in [
        ...navigationFor(policy, maxTabs: maxTabs).overflow,
        ...secondary(policy),
      ])
        if (paths.add(feature.path)) feature,
    ];
  }

  List<AppFeature> secondary(AccessPolicy policy) =>
      allowed(policy).where((f) => f.tab == null).toList(growable: false);

  bool canOpen(String location, AccessPolicy policy) {
    final path = Uri.parse(location).path;
    final owners = features.where(
      (f) => path == f.path || path.startsWith('${f.path}/'),
    );
    if (owners.isEmpty) return true;
    final longest = owners
        .map((f) => f.path.length)
        .reduce((a, b) => a > b ? a : b);
    return owners
        .where((f) => f.path.length == longest)
        .any((f) => f.allowedFor(policy));
  }
}
