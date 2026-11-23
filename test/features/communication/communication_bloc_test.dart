import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/bloc/notice_detail_bloc.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/bloc/notice_detail_event.dart';
import 'package:super_flutter/features/communication/presentation/notice_detail/bloc/notice_detail_state.dart';
import 'package:super_flutter/features/communication/presentation/notices/bloc/notices_bloc.dart';
import 'package:super_flutter/features/communication/presentation/notices/bloc/notices_event.dart';
import 'package:super_flutter/features/communication/presentation/notices/bloc/notices_state.dart';
import 'package:super_flutter/features/communication/presentation/alerts/bloc/alerts_bloc.dart';
import 'package:super_flutter/features/communication/presentation/alerts/bloc/alerts_event.dart';
import 'package:super_flutter/features/communication/presentation/alerts/bloc/alerts_state.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';

class MockSource extends Mock implements CommunicationRemoteDataSource {}

final _notice = NoticeModel(
  id: 'n1',
  title: 'Crop insurance',
  body: 'Full body text of the notice for farmers.',
  category: CategoryModel(id: 'c1', name: 'Schemes'),
  priority: PriorityModel(value: 'high', label: 'High'),
  publishedAt: DateTime(2026, 6, 10),
);

final _page1 = Paged(
  items: List.generate(20, (i) => NoticeModel(id: 'n$i', title: 'Notice $i')),
  page: 1,
  lastPage: 3,
  perPage: 20,
  total: 45,
);

final _page2 = Paged(
  items: List.generate(20, (i) => NoticeModel(id: 'n${20 + i}', title: 'Notice ${20 + i}')),
  page: 2,
  lastPage: 3,
  perPage: 20,
  total: 45,
);

final _alertPage1 = Paged(
  items: [
    AlertModel(
      id: 'a1',
      title: 'Heavy rain',
      severity: SeverityModel(value: 'emergency', label: 'Emergency'),
    ),
  ],
  page: 1,
  lastPage: 2,
  perPage: 20,
  total: 25,
);

final _alertPage2 = Paged(
  items: [
    AlertModel(id: 'a2', title: 'Pest watch'),
  ],
  page: 2,
  lastPage: 2,
  perPage: 20,
  total: 25,
);

void main() {
  late MockSource source;

  setUp(() {
    source = MockSource();
  });

  // ─── NoticeDetailBloc ───

  group('NoticeDetailBloc', () {
    blocTest<NoticeDetailBloc, NoticeDetailState>(
      'loads a notice',
      setUp: () => when(() => source.getNotice(any())).thenAnswer(
        (_) async => _notice,
      ),
      build: () => NoticeDetailBloc(source),
      act: (b) => b.add(const NoticeDetailStarted(noticeId: 'n1')),
      expect: () => [
        const NoticeDetailState(status: NoticeDetailStatus.loading),
        NoticeDetailState(status: NoticeDetailStatus.loaded, notice: _notice),
      ],
      verify: (_) => verify(() => source.getNotice('n1')).called(1),
    );

    blocTest<NoticeDetailBloc, NoticeDetailState>(
      'failure shows error',
      setUp: () => when(() => source.getNotice(any())).thenThrow(
        const UnknownException('Offline'),
      ),
      build: () => NoticeDetailBloc(source),
      act: (b) => b.add(const NoticeDetailStarted(noticeId: 'n1')),
      skip: 1,
      expect: () => [
        const NoticeDetailState(
          status: NoticeDetailStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );
  });

  // ─── NoticesBloc ───

  group('NoticesBloc', () {
    void answerNotices({bool fail = false}) {
      when(
        () => source.getNotices(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer(
        (_) => fail
            ? Future.error(const UnknownException('Offline'))
            : Future.value(_page1),
      );
    }

    blocTest<NoticesBloc, NoticesState>(
      'loads the first page',
      setUp: answerNotices,
      build: () => NoticesBloc(source),
      act: (b) => b.add(const NoticesStarted()),
      expect: () => [
        const NoticesState(status: NoticesStatus.loading),
        NoticesState(status: NoticesStatus.loaded, notices: _page1),
      ],
      verify: (_) =>
          verify(() => source.getNotices(page: 1, perPage: 20)).called(1),
    );

    blocTest<NoticesBloc, NoticesState>(
      'failure shows error',
      setUp: () => answerNotices(fail: true),
      build: () => NoticesBloc(source),
      act: (b) => b.add(const NoticesStarted()),
      skip: 1,
      expect: () => [
        const NoticesState(
          status: NoticesStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );

    blocTest<NoticesBloc, NoticesState>(
      'loads the next page',
      setUp: () {
        when(
          () => source.getNotices(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _page2);
      },
      build: () => NoticesBloc(source),
      seed: () => NoticesState(status: NoticesStatus.loaded, notices: _page1),
      act: (b) => b.add(const NoticesMoreRequested()),
      expect: () => [
        NoticesState(
          status: NoticesStatus.loaded,
          notices: _page1,
          loadingMore: true,
        ),
        NoticesState(
          status: NoticesStatus.loaded,
          notices: _page1.append(_page2),
          loadingMore: false,
        ),
      ],
    );
  });

  // ─── AlertsBloc ───

  group('AlertsBloc', () {
    void answerAlerts({bool fail = false}) {
      when(
        () => source.getAlerts(
          districtId: any(named: 'districtId'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer(
        (_) => fail
            ? Future.error(const UnknownException('Offline'))
            : Future.value(_alertPage1),
      );
    }

    blocTest<AlertsBloc, AlertsState>(
      'loads the first page',
      setUp: answerAlerts,
      build: () => AlertsBloc(source),
      act: (b) => b.add(const AlertsStarted()),
      expect: () => [
        const AlertsState(status: AlertsStatus.loading),
        AlertsState(status: AlertsStatus.loaded, alerts: _alertPage1),
      ],
      verify: (_) =>
          verify(() => source.getAlerts(page: 1, perPage: 20)).called(1),
    );

    blocTest<AlertsBloc, AlertsState>(
      'failure shows error',
      setUp: () => answerAlerts(fail: true),
      build: () => AlertsBloc(source),
      act: (b) => b.add(const AlertsStarted()),
      skip: 1,
      expect: () => [
        const AlertsState(
          status: AlertsStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );

    blocTest<AlertsBloc, AlertsState>(
      'loads the next page',
      setUp: () {
        when(
          () => source.getAlerts(
            districtId: any(named: 'districtId'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => _alertPage2);
      },
      build: () => AlertsBloc(source),
      seed: () => AlertsState(status: AlertsStatus.loaded, alerts: _alertPage1),
      act: (b) => b.add(const AlertsMoreRequested()),
      expect: () => [
        AlertsState(
          status: AlertsStatus.loaded,
          alerts: _alertPage1,
          loadingMore: true,
        ),
        AlertsState(
          status: AlertsStatus.loaded,
          alerts: _alertPage1.append(_alertPage2),
          loadingMore: false,
        ),
      ],
    );
  });
}
