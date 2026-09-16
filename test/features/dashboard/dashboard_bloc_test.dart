import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/domain/auth/use_cases/logout.dart';
import 'package:starter/features/auth/session/bloc/auth_cubit.dart';
import 'package:starter/features/dashboard/dashboard/bloc/dashboard_bloc.dart';
import 'package:starter/features/dashboard/dashboard/bloc/dashboard_event.dart';
import 'package:starter/features/dashboard/dashboard/bloc/dashboard_state.dart';

class MockLogout extends Mock implements Logout {}

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockLogout logout;
  late MockAuthCubit authCubit;

  setUp(() {
    logout = MockLogout();
    authCubit = MockAuthCubit();
    when(() => logout()).thenAnswer((_) async {});
    when(() => authCubit.unauthenticated()).thenReturn(null);
  });

  blocTest<DashboardBloc, DashboardState>(
    'calls logout use-case then reflects unauthenticated status',
    build: () => DashboardBloc(logout, authCubit),
    act: (b) => b.add(const DashboardSignOutRequested()),
    expect: () => [
      const DashboardState(status: DashboardStatus.submitting),
      const DashboardState(status: DashboardStatus.success),
    ],
    verify: (_) {
      verify(() => logout()).called(1);
      verify(() => authCubit.unauthenticated()).called(1);
    },
  );
}
