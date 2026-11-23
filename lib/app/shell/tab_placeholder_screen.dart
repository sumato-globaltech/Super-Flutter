import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';

import '../access/feature_registry.dart';

/// Stands in for a tab whose feature is not built yet, so the shell can be
/// reviewed with every destination in place.
class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({required this.feature, super.key});

  final AppFeature? feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(
        title: feature?.title(l10n) ?? l10n.comingSoon,
      ),
      body: SafeArea(
        child: AppEmptyView(
          title: l10n.comingSoon,
          message: l10n.comingSoonMessage,
          icon: feature?.icon ?? PhosphorIconsRegular.hourglass,
        ),
      ),
    );
  }
}
