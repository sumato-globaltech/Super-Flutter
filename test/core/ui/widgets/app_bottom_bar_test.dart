import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/ui/widgets/app_bottom_bar.dart';

import 'widget_harness.dart';

const _items = [
  AppBottomBarItem(
    icon: PhosphorIconsRegular.house,
    activeIcon: PhosphorIconsFill.house,
    label: 'Home',
  ),
  AppBottomBarItem(
    icon: PhosphorIconsRegular.storefront,
    activeIcon: PhosphorIconsFill.storefront,
    label: 'Market',
  ),
  AppBottomBarItem(
    icon: PhosphorIconsRegular.plant,
    label: 'Farms',
    badgeCount: 3,
  ),
  AppBottomBarItem(
    icon: PhosphorIconsRegular.user,
    label: 'Profile',
    showDot: true,
  ),
];

Future<List<int>> pumpBar(
  WidgetTester tester, {
  List<AppBottomBarItem> items = _items,
  int selected = 0,
  bool dark = false,
  double bottomInset = 0,
  double textScale = 1,
}) async {
  final taps = <int>[];
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        padding: EdgeInsets.only(bottom: bottomInset),
        textScaler: TextScaler.linear(textScale),
      ),
      child: themedApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: AppBottomBar(
            items: items,
            selectedIndex: selected,
            onSelected: taps.add,
          ),
        ),
        dark: dark,
      ),
    ),
  );
  return taps;
}

void main() {
  testWidgets('shows every destination and the active icon', (tester) async {
    await pumpBar(tester);

    for (final label in ['Home', 'Market', 'Farms', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(PhosphorIconsFill.house), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.house), findsNothing);
    expect(find.byIcon(PhosphorIconsRegular.storefront), findsOneWidget);
  });

  testWidgets('selected and unselected colours come from the theme', (
    tester,
  ) async {
    await pumpBar(tester);
    final theme = Theme.of(tester.element(find.byType(AppBottomBar)));
    final nav = theme.bottomNavigationBarTheme;

    final home = tester.widget<Icon>(find.byIcon(PhosphorIconsFill.house));
    final market = tester.widget<Icon>(
      find.byIcon(PhosphorIconsRegular.storefront),
    );
    expect(home.color, nav.selectedItemColor);
    expect(market.color, nav.unselectedItemColor);
  });

  testWidgets('reports taps, including on the current tab', (tester) async {
    final taps = await pumpBar(tester, selected: 1);

    await tester.tap(find.text('Farms'));
    await tester.tap(find.text('Market'));

    expect(taps, [2, 1]);
  });

  testWidgets('shows badge counts and dots', (tester) async {
    await pumpBar(
      tester,
      items: [
        ..._items.take(2),
        const AppBottomBarItem(
          icon: PhosphorIconsRegular.bell,
          label: 'Alerts',
          badgeCount: 250,
        ),
        _items[3],
      ],
    );

    expect(find.text('99+'), findsOneWidget);
    final badges = tester.widgetList<Badge>(find.byType(Badge)).toList();
    expect(badges.where((b) => b.isLabelVisible), hasLength(2));
  });

  testWidgets('marks the selected destination for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpBar(tester, selected: 1);

    expect(
      tester.getSemantics(find.text('Market')),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
        label: 'Market',
      ),
    );
    semantics.dispose();
  });

  testWidgets('sits above the system navigation inset', (tester) async {
    await pumpBar(tester, bottomInset: 34);

    final size = tester.getSize(find.byType(BottomAppBar));
    expect(size.height, 64 + 34);
  });

  testWidgets('large text does not overflow', (tester) async {
    await pumpBar(tester, textScale: 2);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in dark mode', (tester) async {
    await pumpBar(tester, dark: true);

    expect(tester.takeException(), isNull);
  });

  test('takes 2 to 5 destinations', () {
    expect(
      () => AppBottomBar(
        items: [_items.first],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
      throwsAssertionError,
    );
    expect(
      () => AppBottomBar(
        items: [..._items, ..._items],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
      throwsAssertionError,
    );
  });
}
