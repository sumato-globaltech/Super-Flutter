import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/ui/widgets/image_preview.dart';
import 'package:super_flutter/core/ui/widgets/shimmer_card.dart';
import 'package:super_flutter/core/ui/widgets/title_details_card.dart';

import 'widget_harness.dart';

const _long =
    'Apply 20 kg of urea per hectare after the first weeding, then irrigate '
    'lightly. Avoid applying before heavy rain, and keep a gap of three weeks '
    'before the second dose so the crop can take up the nitrogen evenly.';

Future<void> pumpCard(
  WidgetTester tester,
  Widget card, {
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
  testWidgets('shows title and value, with top spacing unless first', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleDetailsCard(
            title: 'Farm area',
            text: '2.5 ha',
            isFirstItem: true,
          ),
          TitleDetailsCard(title: 'District', text: 'Kohima'),
        ],
      ),
    );

    expect(find.text('Farm area'), findsOneWidget);
    expect(find.text('2.5 ha'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Farm area')).dy, 0);
    final gap =
        tester.getTopLeft(find.text('District')).dy -
        tester.getBottomLeft(find.text('2.5 ha')).dy;
    expect(gap, greaterThanOrEqualTo(12));
  });

  testWidgets('icon chip and link mark when tappable', (tester) async {
    var taps = 0;
    await pumpCard(
      tester,
      TitleDetailsCard(
        title: 'District',
        text: 'Kohima',
        iconData: PhosphorIconsRegular.mapPin,
        accentColor: Colors.blue,
        onTap: () => taps++,
      ),
    );

    expect(find.byIcon(PhosphorIconsRegular.mapPin), findsOneWidget);
    expect(find.byIcon(PhosphorIconsBold.link), findsOneWidget);
    await tester.tap(find.text('Kohima'));
    expect(taps, 1);
  });

  testWidgets('loading shows a shimmer instead of the value', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Balance',
        text: '₹ 1,200',
        isTextLoading: true,
      ),
    );

    expect(find.byType(ShimmerCard), findsOneWidget);
    expect(find.text('₹ 1,200'), findsNothing);
  });

  testWidgets('copies the value and confirms with a tick', (tester) async {
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

    await tester.tap(find.byIcon(PhosphorIconsRegular.copy));
    await tester.pumpAndSettle();
    expect(clipboard, 'FRM-2026-0042');
    expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byIcon(PhosphorIconsRegular.copy), findsOneWidget);
  });

  testWidgets('read more cuts long text and opens it in a ConfirmSheet', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Advisory', text: _long, isReadMore: true),
      width: 260,
    );

    expect(find.text(_long), findsNothing);
    await tester.tapOnText(find.textRange.ofSubstring('more'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text(_long), findsOneWidget);
  });

  testWidgets('short text with read more is shown whole', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Crop', text: 'Paddy', isReadMore: true),
    );

    expect(find.text('Paddy'), findsOneWidget);
  });

  testWidgets('thumbnails open the full-screen preview', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Photos',
        imagePreviewUrls: ['https://example.test/a.jpg', null, ''],
      ),
    );

    final thumbnails = find.byType(CachedNetworkImage);
    expect(thumbnails, findsOneWidget);
    await tester.tap(thumbnails);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ImagePreview), findsOneWidget);
  });

  testWidgets('an empty photo list hides the card', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(title: 'Photos', imagePreviewUrls: []),
    );

    expect(find.text('Photos'), findsNothing);
  });

  testWidgets('aligns to the end', (tester) async {
    await pumpCard(
      tester,
      const TitleDetailsCard(
        title: 'Total',
        text: '₹ 4,500',
        isCrossAxisAlignmentStart: false,
      ),
    );

    expect(tester.widget<Text>(find.text('₹ 4,500')).textAlign, TextAlign.end);
  });

  testWidgets('renders every variant in dark mode', (tester) async {
    await pumpCard(
      tester,
      const Column(
        children: [
          TitleDetailsCard(
            title: 'Advisory',
            text: _long,
            iconData: PhosphorIconsRegular.info,
            isReadMore: true,
            isFirstItem: true,
          ),
          TitleDetailsCard(title: 'ID', text: 'X-1', isCopyable: true),
          TitleDetailsCard(title: 'Balance', text: '', isTextLoading: true),
        ],
      ),
      dark: true,
    );

    expect(tester.takeException(), isNull);
  });
}
