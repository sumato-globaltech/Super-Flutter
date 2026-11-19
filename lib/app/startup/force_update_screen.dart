import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/assets_names.dart';
import '../../core/constants/design_colors.dart';

/// Shown when the installed build is below the Remote Config minimum.
///
/// [storeLink] comes from Remote Config `store_links` for this platform.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, required this.storeLink});

  final String? storeLink;

  static String get _storeName =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'App Store' : 'Google Play';

  Future<void> _openStore(BuildContext context) async {
    final uri = storeLink == null ? null : Uri.tryParse(storeLink!);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Please contact the admin to update.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: AssetsName.appLogo,
                      child: Image.asset(
                        AssetsName.appLogo,
                        width: 200,
                        height: 200,
                        gaplessPlayback: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'A new version of your app is available on $_storeName!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openStore(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColor.backgroundBlack,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Update Now',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
