import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/ui/theme/app_colors.dart';
import 'package:super_flutter/core/ui/widgets/design_card.dart';

import 'widget_harness.dart';

void main() {
  testWidgets('shows the title, actions and child on an inner card', (
    tester,
  ) async {
    await tester.pumpWidget(
      themedApp(
        DesignCard(
          title: 'Farm Details',
          actions: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ],
          child: const Text('2.5 ha'),
        ),
      ),
    );

    expect(find.text('Farm Details'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.text('2.5 ha'), findsOneWidget);
  });

  testWidgets('each of children gets its own inner card', (tester) async {
    await tester.pumpWidget(
      themedApp(
        const DesignCard(children: [Text('one'), Text('two'), Text('three')]),
      ),
    );

    for (final text in ['one', 'two', 'three']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byType(ClipRRect), findsNWidgets(3));
  });

  testWidgets('calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themedApp(DesignCard(onTap: () => taps++, child: const Text('Open'))),
    );

    await tester.tap(find.text('Open'));
    expect(taps, 1);
  });

  testWidgets('uses the dark card colours in dark mode', (tester) async {
    await tester.pumpWidget(
      themedApp(const DesignCard(child: Text('x')), dark: true),
    );

    final colors = Theme.of(tester.element(find.text('x'))).appColors;
    final outer = tester
        .widgetList<Ink>(find.byType(Ink))
        .map((ink) => (ink.decoration as BoxDecoration?)?.color)
        .toList();
    expect(outer, containsAll([colors.cardWrapper, colors.cardContent]));
    expect(colors.cardContent, AppColorsExt.dark.cardContent);
    expect(tester.takeException(), isNull);
  });
}
