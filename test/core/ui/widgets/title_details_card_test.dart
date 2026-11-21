import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/ui/widgets/app_network_image.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';

import 'widget_harness.dart';

const _long =
    'Apply 20 kg of urea per hectare after the first weeding, then irrigate '
    'lightly. Avoid applying before heavy rain, and keep a gap of three weeks '
    'before the second dose so the crop can take up the nitrogen evenly.';

Future<void> pumpCard(
  WidgetTester tester,
  TitleDetailsCard card, {
  double width = 360,
  bool dark = false,
}) {
  return tester.pumpWidget(
    themedApp(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: card),
      ),
      dark: dark,
    ),
  );
}

void main() {
  testWidgets('shows the title and value', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Farm area', text: '2.5 ha'),
    );

    expect(find.text('Farm area'), findsOneWidget);
    expect(find.text('2.5 ha'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsBold.link), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('a tappable card shows the link mark and calls back', (
    tester,
  ) async {
    var taps = 0;
    await pumpCard(
      tester,
      TitleDetailsCard(
        title: 'District',
        text: 'Kohima',
        icon: PhosphorIconsRegular.info,
        onTap: () => taps++,
      ),
    );

    expect(find.byIcon(PhosphorIconsBold.link), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.info), findsOneWidget);
    await tester.tap(find.text('Kohima'));
    expect(taps, 1);
  });

  testWidgets('loading shows a skeleton instead of the value', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Balance',
        text: '₹ 1,200',
        isLoading: true,
      ),
    );

    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('₹ 1,200'), findsNothing);
  });

  testWidgets('child is shown when there is no text', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Status',
        child: Chip(label: Text('Active')),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('copies the value and confirms it', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Farmer ID',
        text: 'FRM-2026-0042',
        isCopyable: true,
      ),
    );

    expect(find.byTooltip('Copy'), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.copy));
    await tester.pumpAndSettle();

    expect(clipboard, 'FRM-2026-0042');
    expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);
    expect(find.byTooltip('Copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byIcon(PhosphorIconsRegular.copy), findsOneWidget);
  });

  testWidgets('long text is cut with "more" that opens the full text', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Advisory', text: _long, readMoreLines: 2),
      width: 260,
    );

    expect(find.textContaining('more', findRichText: true), findsOneWidget);
    expect(find.text(_long), findsNothing);

    await tester.tapOnText(find.textRange.ofSubstring('more'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text(_long), findsOneWidget);
  });

  testWidgets('short text with read more is shown whole', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Crop', text: 'Paddy', readMoreLines: 2),
    );

    expect(find.text('Paddy'), findsOneWidget);
    expect(find.textContaining('more', findRichText: true), findsNothing);
  });

  testWidgets('thumbnails report which image was tapped', (tester) async {
    final tapped = <int>[];
    await pumpCard(
      tester,
      TitleDetailsCard(
        title: 'Photos',
        imageUrls: const ['', ''],
        onImageTap: tapped.add,
      ),
    );

    expect(find.byType(AppNetworkImage), findsNWidgets(2));
    await tester.tap(find.byType(AppNetworkImage).last);
    expect(tapped, [1]);
  });

  testWidgets('aligns to the end', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Total', text: '₹ 4,500', alignEnd: true),
    );

    final value = tester.widget<Text>(find.text('₹ 4,500'));
    expect(value.textAlign, TextAlign.end);
  });

  testWidgets('renders every variant in dark mode', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Advisory',
        text: _long,
        icon: PhosphorIconsRegular.info,
        readMoreLines: 2,
        isCopyable: true,
      ),
      dark: true,
    );

    expect(tester.takeException(), isNull);
  });
}
