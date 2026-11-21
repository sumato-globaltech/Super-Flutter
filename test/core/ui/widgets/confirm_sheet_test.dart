import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/core/ui/widgets/progress_circle.dart';

import 'widget_harness.dart';

void main() {
  testWidgets('has the close button above the sheet, title and description', (
    tester,
  ) async {
    await openFrom(tester, (context) {
      ConfirmSheet.show<void>(
        context,
        const ConfirmSheet(
          title: 'Safety tips',
          description: 'Wear gloves when handling fertilizer.',
          icon: Icon(PhosphorIconsRegular.info, size: 35),
        ),
      );
    });

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Safety tips'), findsOneWidget);
    expect(find.text('Wear gloves when handling fertilizer.'), findsOneWidget);
    expect(
      tester.getCenter(find.byIcon(Icons.close)).dy,
      lessThan(tester.getTopLeft(find.text('Safety tips')).dy),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Safety tips'), findsNothing);
  });

  testWidgets('shows the app logo when there is no icon, actions or child', (
    tester,
  ) async {
    await openFrom(tester, (context) {
      ConfirmSheet.show<void>(
        context,
        const ConfirmSheet(title: 'Welcome', description: ''),
      );
    });

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('confirm returns true and uses Done by default', (tester) async {
    bool? result;
    await openFrom(tester, (context) async {
      result = await ConfirmSheet.confirm(context, title: 'Sign out?');
    });

    expect(find.text('Done'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('closing without confirming returns false', (tester) async {
    bool? result;
    await openFrom(tester, (context) async {
      result = await ConfirmSheet.confirm(context, title: 'Sign out?');
    });

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('spins, blocks closing and repeat taps while the action runs', (
    tester,
  ) async {
    final done = Completer<void>();
    var calls = 0;
    bool? result;
    await openFrom(tester, (context) async {
      result = await ConfirmSheet.confirm(
        context,
        title: 'Archive farm?',
        confirmText: 'Archive',
        onConfirm: () {
          calls++;
          return done.future;
        },
      );
    });

    await tester.tap(find.text('Archive'));
    await tester.pump();
    expect(find.byType(DesignProgress), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.tap(find.byIcon(Icons.close));
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Archive farm?'), findsOneWidget);
    expect(calls, 1);

    done.complete();
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('a failure stays on the sheet with its message', (tester) async {
    var calls = 0;
    bool? result;
    await openFrom(tester, (context) async {
      result = await ConfirmSheet.confirm(
        context,
        title: 'Cancel shipment?',
        onConfirm: () async {
          if (++calls == 1) {
            throw const BadRequestException('Already picked up.');
          }
        },
      );
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Already picked up.'), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('an unexpected error shows the generic message', (tester) async {
    await openFrom(tester, (context) {
      ConfirmSheet.confirm(
        context,
        title: 'Sync?',
        onConfirm: () async => throw StateError('boom'),
      );
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('a non-dismissible sheet cannot be closed', (tester) async {
    await openFrom(tester, (context) {
      ConfirmSheet.show<void>(
        context,
        ConfirmSheet(
          title: 'Update required',
          description: '',
          isDismissible: false,
          onPressed: () async {},
        ),
      );
    });

    await tester.tap(find.byIcon(Icons.close));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('confirm colour paints the button', (tester) async {
    await openFrom(tester, (context) {
      ConfirmSheet.confirm(
        context,
        title: 'Delete farm?',
        confirmText: 'Delete',
        confirmColor: Colors.red,
      );
    });

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.backgroundColor?.resolve({}), Colors.red);
  });

  testWidgets('choose returns the tapped action and marks the selected one', (
    tester,
  ) async {
    String? picked;
    await openFrom(tester, (context) async {
      picked = await ConfirmSheet.choose<String>(
        context,
        title: 'Sort by',
        actions: const [
          SheetAction(value: 'name', label: 'Name', selected: true),
          SheetAction(value: 'price', label: 'Price'),
          SheetAction(value: 'clear', label: 'Clear', isDestructive: true),
        ],
      );
    });

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(Image), findsNothing);

    await tester.tap(find.text('Price'));
    await tester.pumpAndSettle();
    expect(picked, 'price');
  });

  testWidgets('the selected tick is visible in light and dark', (tester) async {
    for (final dark in [false, true]) {
      await openFrom(tester, dark: dark, (context) {
        ConfirmSheet.choose<String>(
          context,
          title: 'Sort by',
          actions: const [SheetAction(value: 'a', label: 'A', selected: true)],
        );
      });
      final check = tester.widget<Icon>(find.byIcon(Icons.check));
      final surface = Theme.of(tester.element(find.byIcon(Icons.check)))
          .colorScheme
          .surface;
      expect(check.color, isNot(surface), reason: dark ? 'dark' : 'light');
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    }
  });
}
