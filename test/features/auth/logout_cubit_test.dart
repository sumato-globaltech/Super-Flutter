import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:starter/domain/auth/use_cases/logout.dart';
import 'package:starter/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/logout_cubit.dart';
import 'package:starter/features/auth/presentation/bloc/logout_state.dart';

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

  blocTest<LogoutCubit, LogoutState>(
    'calls logout use-case then reflects unauthenticated status',
    build: () => LogoutCubit(logout, authCubit),
    act: (c) => c.submit(),
    expect: () => [
      const LogoutState(status: LogoutStatus.submitting),
      const LogoutState(status: LogoutStatus.success),
    ],
    verify: (_) {
      verify(() => logout()).called(1);
      verify(() => authCubit.unauthenticated()).called(1);
    },
  );
}
