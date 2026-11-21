import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/core/ui/widgets/app_top_bar.dart';

import 'widget_harness.dart';

void main() {
  testWidgets('shows the title at the standard height', (tester) async {
    const bar = AppTopBar(title: 'Farms');
    await tester.pumpWidget(themedApp(const Column(children: [bar])));

    expect(find.text('Farms'), findsOneWidget);
    expect(bar.preferredSize.height, kToolbarHeight);
    expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
  });

  testWidgets('a subtitle adds a second line and grows the bar', (
    tester,
  ) async {
    const bar = AppTopBar(title: 'East field', subtitle: 'Kohima · 2.5 ha');
    await tester.pumpWidget(themedApp(const Column(children: [bar])));

    expect(find.text('East field'), findsOneWidget);
    expect(find.text('Kohima · 2.5 ha'), findsOneWidget);
    expect(bar.preferredSize.height, kToolbarHeight + 8);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a bottom widget adds its height', (tester) async {
    const bar = AppTopBar(
      title: 'Schemes',
      bottom: TabBar(
        tabs: [
          Tab(text: 'Open'),
          Tab(text: 'Applied'),
        ],
      ),
    );
    await tester.pumpWidget(
      themedApp(
        const DefaultTabController(length: 2, child: Scaffold(appBar: bar)),
      ),
    );

    expect(bar.preferredSize.height, kToolbarHeight + kTextTabBarHeight);
    expect(
      tester.getSize(find.byType(AppBar)).height,
      kToolbarHeight + kTextTabBarHeight,
    );
    expect(find.text('Applied'), findsOneWidget);
  });

  testWidgets('shows a back button on a pushed screen', (tester) async {
    await tester.pumpWidget(
      themedApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(appBar: AppTopBar(title: 'Farm detail')),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Farm detail'), findsNothing);
  });

  testWidgets('actions are shown', (tester) async {
    await tester.pumpWidget(
      themedApp(
        Column(
          children: [
            AppTopBar(
              title: 'Farms',
              actions: [
                IconButton(
                  tooltip: 'Add',
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.byTooltip('Add'), findsOneWidget);
  });

  testWidgets('sliver bar floats on the page background', (tester) async {
    await tester.pumpWidget(
      themedApp(
        CustomScrollView(
          slivers: [
            const AppSliverTopBar(title: 'Home', subtitle: 'Good morning'),
            SliverList.list(
              children: [for (var i = 0; i < 30; i++) Text('row $i')],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    final sliver = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    final theme = Theme.of(tester.element(find.byType(SliverAppBar)));
    expect(sliver.backgroundColor, theme.scaffoldBackgroundColor);
    expect(sliver.floating && sliver.snap, isTrue);
  });

  test('title and titleWidget are exclusive', () {
    expect(
      () => AppTopBar(title: 'A', titleWidget: Text('B')),
      throwsAssertionError,
    );
  });
}
