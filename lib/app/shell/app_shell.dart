import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/app_bottom_bar.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';

import '../access/app_features.dart';
import '../access/feature_registry.dart';

class AppShell extends StatelessWidget {
  AppShell({
    required this.navigationShell,
    FeatureRegistry? registry,
    super.key,
  }) : registry = registry ?? appFeatures;

  final StatefulNavigationShell navigationShell;
  final FeatureRegistry registry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final access = context.select((AuthCubit cubit) => cubit.state.access);
    final layout = registry.navigationFor(access);
    final paths = registry.tabPaths;
    final current = navigationShell.currentIndex;
    int branchOf(AppFeature feature) => paths.indexOf(feature.path);

    final tabs = layout.tabs;
    final overflow = layout.overflow;
    final tabIndex = tabs.indexWhere((f) => branchOf(f) == current);
    final inOverflow = overflow.any((f) => branchOf(f) == current);
    final selected = tabIndex >= 0
        ? tabIndex
        : inOverflow
        ? tabs.length
        : 0;
    final homeBranch = tabs.isEmpty ? 0 : branchOf(tabs.first);

    void open(int branch) =>
        navigationShell.goBranch(branch, initialLocation: branch == current);

    Future<void> openMore() async {
      final branch = await ConfirmSheet.choose<int>(
        context,
        title: l10n.more,
        actions: [
          for (final feature in overflow)
            SheetAction(
              value: branchOf(feature),
              label: feature.title(l10n),
              icon: feature.icon,
              selected: branchOf(feature) == current,
            ),
        ],
      );
      if (branch != null) open(branch);
    }

    final items = [
      for (final feature in tabs)
        AppBottomBarItem(
          icon: feature.tab!.icon,
          activeIcon: feature.tab!.activeIcon,
          label: feature.title(l10n),
        ),
      if (layout.hasMore)
        AppBottomBarItem(
          icon: PhosphorIconsRegular.dotsThreeOutline,
          activeIcon: PhosphorIconsFill.dotsThreeOutline,
          label: l10n.more,
        ),
    ];

    return PopScope(
      canPop: current == homeBranch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) open(homeBranch);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: items.length < 2
            ? null
            : AppBottomBar(
                items: items,
                selectedIndex: selected,
                onSelected: (index) => index < tabs.length
                    ? open(branchOf(tabs[index]))
                    : openMore(),
              ),
      ),
    );
  }
}
