import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/confirm_sheet.dart';
import 'package:super_flutter/data/help_desk/model/queue_summary_model.dart';
import 'package:super_flutter/data/help_desk/sources/remote/help_desk_remote_data_source.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/data/support/model/call_center_model.dart';
import 'package:super_flutter/data/support/model/ticket_model.dart';
import 'package:super_flutter/data/support/sources/remote/support_remote_data_source.dart';
import 'package:super_flutter/features/help_desk/presentation/queue_summary/bloc/queue_summary_bloc.dart';
import 'package:super_flutter/features/help_desk/presentation/queue_summary/screen/queue_summary_screen.dart';
import 'package:super_flutter/features/support/presentation/support/bloc/support_bloc.dart';
import 'package:super_flutter/features/support/presentation/support/bloc/support_event.dart';
import 'package:super_flutter/features/support/presentation/support/bloc/support_state.dart';
import 'package:super_flutter/features/support/presentation/support/screen/support_screen.dart';
import 'package:super_flutter/features/support/presentation/ticket_detail/bloc/ticket_detail_bloc.dart';
import 'package:super_flutter/features/support/presentation/ticket_detail/screen/ticket_detail_screen.dart';
import 'package:super_flutter/features/support/routes/support_route_names.dart';

class _MockSupport extends Mock implements SupportRemoteDataSource {}

class _MockHelpDesk extends Mock implements HelpDeskRemoteDataSource {}

void main() {
  late _MockSupport source;
  late _MockHelpDesk helpDesk;
  final ticket = TicketModel(
    id: 't1',
    number: 'TKT-000001',
    subject: 'Leaf spots',
    question: 'What is this?',
    status: StatusModel(value: 'open', label: 'Open'),
    replies: [ReplyModel(id: 'r1', body: 'Spray neem oil')],
  );

  setUp(() async {
    source = _MockSupport();
    helpDesk = _MockHelpDesk();
    await getIt.reset();
    getIt
      ..registerFactory(() => SupportBloc(source))
      ..registerFactory(() => TicketDetailBloc(source))
      ..registerFactory(() => QueueSummaryBloc(helpDesk));
    when(() => source.getTickets(page: 1, perPage: any(named: 'perPage')))
        .thenAnswer((_) async => Paged(items: [ticket]));
    when(() => source.getCallCenter()).thenAnswer(
      (_) async => CallCenterModel(district: 'Kohima', number: '18001801551'),
    );
    when(() => source.getTicket('t1')).thenAnswer((_) async => ticket);
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => home),
            GoRoute(
              path: SupportRouteNames.ticketDetail,
              builder: (_, state) =>
                  TicketDetailScreen(ticket: state.pathParameters['ticket']!),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SupportBloc', () {
    test('tickets load even when the call center fails', () async {
      when(() => source.getCallCenter()).thenAnswer((_) async {
        throw Exception();
      });
      final bloc = SupportBloc(source)..add(const SupportStarted());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == SupportStatus.success,
      );
      expect(state.tickets?.items, [ticket]);
      expect(state.callCenter, isNull);
      await bloc.close();
    });

    test('a refused call back reaches the sheet', () async {
      when(() => source.createCallBack(question: any(named: 'question')))
          .thenThrow(const ValidationException('Too many requests.'));
      final bloc = SupportBloc(source);
      final completer = Completer<void>();
      bloc.add(SupportCallBackRequested(completer: completer));
      await expectLater(completer.future, throwsA(isA<ValidationException>()));
      await bloc.close();
    });
  });

  testWidgets('farmer sees the number and tickets, and asks for a call', (
    tester,
  ) async {
    when(() => source.createCallBack(question: 'Leaves'))
        .thenAnswer((_) async => true);
    await pump(tester, const SupportScreen());
    expect(find.text('18001801551'), findsOneWidget);
    expect(find.text('Leaf spots'), findsOneWidget);

    await tester.tap(find.text('Request a call back'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Leaves');
    await tester.tap(find.text('Request call'));
    await tester.pumpAndSettle();

    verify(() => source.createCallBack(question: 'Leaves')).called(1);
    expect(find.byType(ConfirmSheet), findsNothing);
    expect(find.text('Call back requested'), findsOneWidget);
  });

  testWidgets('a ticket opens with its status and replies', (tester) async {
    await pump(tester, const SupportScreen());
    await tester.tap(find.text('Leaf spots'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(find.textContaining('Spray neem oil'), findsOneWidget);
  });

  testWidgets('an agent sees the queue counts', (tester) async {
    when(() => helpDesk.getQueueSummary()).thenAnswer(
      (_) async => QueueSummaryModel(
        open: 11,
        overdueFollowUps: 22,
        resolvedToday: 33,
        unassigned: 44,
      ),
    );
    await pump(tester, const QueueSummaryScreen());
    for (final count in ['11', '22', '33', '44']) {
      expect(find.text(count), findsOneWidget);
    }
  });

  testWidgets('a tall form sheet fits above the keyboard', (tester) async {
    await pump(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => ConfirmSheet.show<void>(
              context,
              ConfirmSheet(
                title: 'Tall',
                description: '',
                onPressed: () async {},
                confirmText: 'Save it',
                child: Column(
                  children: [
                    for (var i = 0; i < 6; i++)
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Field $i'),
                      ),
                  ],
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Save it'));
    await tester.pumpAndSettle();
    expect(tester.getBottomLeft(find.text('Save it')).dy, lessThan(844 - 336));
  });
}
