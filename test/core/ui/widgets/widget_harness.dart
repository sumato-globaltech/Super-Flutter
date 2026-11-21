import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';

Widget themedApp(Widget home, {bool dark = false}) => MaterialApp(
  theme: AppTheme.light(Flavor.development),
  darkTheme: AppTheme.dark(Flavor.development),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

Future<void> openFrom(
  WidgetTester tester,
  void Function(BuildContext context) open, {
  bool dark = false,
}) async {
  await tester.pumpWidget(
    themedApp(
      Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
      dark: dark,
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
