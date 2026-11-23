import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/banner_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/communication/sources/remote/communication_remote_data_source.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_state.dart';

class MockLogout extends Mock implements Logout {}

class MockSource extends Mock implements CommunicationRemoteDataSource {}

final _banners = [BannerModel(id: 'b1', title: 'Seeds')];
final _alerts = [AlertModel(id: 'a1', title: 'Rain')];
final _notices = [NoticeModel(id: 'n1', title: 'Insurance')];

void main() {
  late MockLogout logout;
  late MockSource source;

  void answer({bool banners = true, bool alerts = true, bool notices = true}) {
    Future<Never> fail() => Future.error(const UnknownException('Offline'));
    when(() => source.getBanners(placement: any(named: 'placement')))
        .thenAnswer((_) => banners ? Future.value(_banners) : fail());
    when(
      () => source.getAlerts(
        districtId: any(named: 'districtId'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) => alerts ? Future.value(Paged(items: _alerts)) : fail());
    when(
      () => source.getNotices(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer(
      (_) => notices ? Future.value(Paged(items: _notices)) : fail(),
    );
  }

  setUp(() {
    logout = MockLogout();
    source = MockSource();
    when(() => logout(allDevices: any(named: 'allDevices')))
        .thenAnswer((_) async {});
  });

  blocTest<DashboardBloc, DashboardState>(
    'calls logout use-case',
    build: () => DashboardBloc(logout, source),
    act: (b) => b.add(const DashboardSignOutRequested()),
    expect: () => [
      const DashboardState(status: DashboardStatus.submitting),
      const DashboardState(status: DashboardStatus.success),
    ],
    verify: (_) => verify(() => logout(allDevices: false)).called(1),
  );

  blocTest<DashboardBloc, DashboardState>(
    'signs out of every device when asked',
    build: () => DashboardBloc(logout, source),
    act: (b) => b.add(const DashboardSignOutRequested(allDevices: true)),
    skip: 1,
    expect: () => [const DashboardState(status: DashboardStatus.success)],
    verify: (_) => verify(() => logout(allDevices: true)).called(1),
  );

  group('home', () {
    blocTest<DashboardBloc, DashboardState>(
      'loads banners, a few alerts and the latest notices',
      setUp: answer,
      build: () => DashboardBloc(logout, source),
      act: (b) => b.add(const DashboardStarted(districtId: 'd1')),
      expect: () => [
        const DashboardState(homeStatus: DashboardHomeStatus.loading),
        DashboardState(
          homeStatus: DashboardHomeStatus.success,
          banners: _banners,
          alerts: _alerts,
          notices: _notices,
        ),
      ],
      verify: (_) {
        verify(() => source.getBanners(placement: 'home')).called(1);
        verify(() => source.getAlerts(districtId: 'd1', page: 1, perPage: 5))
            .called(1);
        verify(() => source.getNotices(page: 1, perPage: 3)).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'a section that fails is left out, the rest shows',
      setUp: () => answer(alerts: false),
      build: () => DashboardBloc(logout, source),
      act: (b) => b.add(const DashboardStarted()),
      skip: 1,
      expect: () => [
        DashboardState(
          homeStatus: DashboardHomeStatus.success,
          banners: _banners,
          notices: _notices,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'nothing loading is a failure with the message',
      setUp: () => answer(banners: false, alerts: false, notices: false),
      build: () => DashboardBloc(logout, source),
      act: (b) => b.add(const DashboardStarted()),
      skip: 1,
      expect: () => [
        const DashboardState(
          homeStatus: DashboardHomeStatus.failure,
          errorMessage: 'Offline',
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'a refresh that fails keeps what was shown',
      setUp: () => answer(banners: false, alerts: false, notices: false),
      build: () => DashboardBloc(logout, source),
      seed: () => DashboardState(
        homeStatus: DashboardHomeStatus.success,
        banners: _banners,
        alerts: _alerts,
        notices: _notices,
      ),
      act: (b) => b.add(const DashboardStarted()),
      skip: 1,
      expect: () => [
        DashboardState(
          homeStatus: DashboardHomeStatus.failure,
          errorMessage: 'Offline',
          banners: _banners,
          alerts: _alerts,
          notices: _notices,
        ),
      ],
    );
  });
}
