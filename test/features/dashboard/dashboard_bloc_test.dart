import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_state.dart';

class MockLogout extends Mock implements Logout {}

void main() {
  late MockLogout logout;

  setUp(() {
    logout = MockLogout();
    when(() => logout()).thenAnswer((_) async {});
  });

  blocTest<DashboardBloc, DashboardState>(
    'calls logout use-case',
    build: () => DashboardBloc(logout),
    act: (b) => b.add(const DashboardSignOutRequested()),
    expect: () => [
      const DashboardState(status: DashboardStatus.submitting),
      const DashboardState(status: DashboardStatus.success),
    ],
    verify: (_) => verify(() => logout()).called(1),
  );
}
