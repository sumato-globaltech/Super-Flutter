import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/features/ui_gallery/presentation/ui_gallery/screen/ui_gallery_screen.dart';

const out = '/private/tmp/claude-501/-Users-deepjyotibaishya-Projects-App-Super-Flutter/c60722a4-2b4a-468d-8643-effb16895545/scratchpad/shots3';

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> shot(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    await loadFont('Inter', [
      for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) 'assets/fonts/Inter-$w.ttf',
    ]);
    const p = '/Users/deepjyotibaishya/.pub-cache/hosted/pub.dev/phosphoricons_flutter-1.1.1/lib/fonts';
    await loadFont('packages/phosphoricons_flutter/PhosphorRegular', ['$p/Phosphor.ttf']);
    await loadFont('packages/phosphoricons_flutter/PhosphorBold', ['$p/Phosphor-Bold.ttf']);
    await loadFont('packages/phosphoricons_flutter/PhosphorFill', ['$p/Phosphor-Fill.ttf']);
    await loadFont('MaterialIcons', ['/Users/deepjyotibaishya/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';
    testWidgets('gallery $mode', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1700 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(Flavor.development),
          darkTheme: AppTheme.dark(Flavor.development),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiGalleryScreen(),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await shot(tester, key, 'gallery_$mode');

      Future<void> sheet(String label, String name, {bool tapConfirm = false, String? confirm}) async {
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 600));
        if (tapConfirm) {
          await tester.tap(find.text(confirm!));
          await tester.pump(const Duration(milliseconds: 1200));
        }
        await shot(tester, key, '${name}_$mode');
        await tester.pump(const Duration(seconds: 3));
        if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.close));
        }
        await tester.pump(const Duration(seconds: 5));
      }

      await sheet('Confirm', 'sheet_confirm');
      await sheet('Destructive', 'sheet_destructive');
      await sheet('Async + logo', 'sheet_logo');
      await sheet('Choose', 'sheet_choose');
      await sheet('Failure', 'sheet_failure', tapConfirm: true, confirm: 'Done');
      await tester.tapOnText(find.textRange.ofSubstring('more'));
      await tester.pump(const Duration(milliseconds: 600));
      await shot(tester, key, 'sheet_readmore_$mode');
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
