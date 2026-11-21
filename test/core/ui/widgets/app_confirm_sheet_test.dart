import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/core/ui/widgets/app_confirm_sheet.dart';

import 'widget_harness.dart';

void main() {
  testWidgets('confirm returns true and closes', (tester) async {
    bool? result;
    await openFrom(tester, (context) async {
      result = await AppConfirmSheet.confirm(
        context,
        title: 'Sign out?',
        message: 'You will need to sign in again.',
        icon: PhosphorIconsRegular.signOut,
      );
    });

    expect(find.text('Sign out?'), findsOneWidget);
    expect(find.text('You will need to sign in again.'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.signOut), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Sign out?'), findsNothing);
  });

  testWidgets('cancel and dismissing return false', (tester) async {
    final results = <bool>[];
    await openFrom(tester, (context) async {
      results.add(await AppConfirmSheet.confirm(context, title: 'Delete?'));
    });

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(results, [false, false]);
  });

  testWidgets('keeps the sheet open while the action runs', (tester) async {
    final done = Completer<void>();
    bool? result;
    await openFrom(tester, (context) async {
      result = await AppConfirmSheet.confirm(
        context,
        title: 'Archive farm?',
        onConfirm: () => done.future,
      );
    });

    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final cancel = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(cancel.onPressed, isNull);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Archive farm?'), findsOneWidget);

    done.complete();
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Archive farm?'), findsNothing);
  });

  testWidgets('cannot be swiped away while the action runs', (tester) async {
    final done = Completer<void>();
    await openFrom(tester, (context) {
      AppConfirmSheet.confirm(
        context,
        title: 'Archive farm?',
        onConfirm: () => done.future,
      );
    });

    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.fling(find.text('Archive farm?'), const Offset(0, 500), 2000);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Archive farm?'), findsOneWidget);
    done.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a sheet without an action can be swiped away', (tester) async {
    bool? result;
    await openFrom(tester, (context) async {
      result = await AppConfirmSheet.confirm(context, title: 'Leave page?');
    });

    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.fling(find.text('Leave page?'), const Offset(0, 500), 2000);
    await tester.pumpAndSettle();

    expect(find.text('Leave page?'), findsNothing);
    expect(result, isFalse);
  });

  testWidgets('shows the failure and lets the user try again', (tester) async {
    var calls = 0;
    bool? result;
    await openFrom(tester, (context) async {
      result = await AppConfirmSheet.confirm(
        context,
        title: 'Cancel shipment?',
        onConfirm: () async {
          calls++;
          if (calls == 1) {
            throw const BadRequestException('Shipment already picked up.');
          }
        },
      );
    });

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Shipment already picked up.'), findsOneWidget);
    expect(find.text('Cancel shipment?'), findsOneWidget);
    expect(result, isNull);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(result, isTrue);
  });

  testWidgets('an unexpected error shows the generic message', (tester) async {
    await openFrom(tester, (context) {
      AppConfirmSheet.confirm(
        context,
        title: 'Sync devices?',
        onConfirm: () async => throw StateError('boom'),
      );
    });

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('destructive confirm uses the error colour', (tester) async {
    await openFrom(tester, (context) {
      AppConfirmSheet.confirm(
        context,
        title: 'Delete farm?',
        confirmLabel: 'Delete',
        isDestructive: true,
      );
    });

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    final context = tester.element(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve({}),
      Theme.of(context).colorScheme.error,
    );
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('choose returns the tapped action value', (tester) async {
    String? picked;
    await openFrom(tester, (context) async {
      picked = await AppConfirmSheet.choose<String>(
        context,
        title: 'Sort by',
        actions: const [
          SheetAction(value: 'name', label: 'Name', selected: true),
          SheetAction(value: 'price', label: 'Price'),
          SheetAction(value: 'remove', label: 'Remove', isDestructive: true),
        ],
      );
    });

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);

    await tester.tap(find.text('Price'));
    await tester.pumpAndSettle();

    expect(picked, 'price');
  });

  testWidgets('renders in dark mode', (tester) async {
    await openFrom(tester, dark: true, (context) {
      AppConfirmSheet.confirm(
        context,
        title: 'Sign out?',
        icon: PhosphorIconsRegular.signOut,
      );
    });

    expect(tester.takeException(), isNull);
    expect(find.text('Sign out?'), findsOneWidget);
  });
}
