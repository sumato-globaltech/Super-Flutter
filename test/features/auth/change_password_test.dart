import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/router/navigator_keys.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/data/auth/sources/remote/auth_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/domain/auth/use_cases/password_changed.dart';
import 'package:super_flutter/features/auth/presentation/change_password/bloc/change_password_bloc.dart';
import 'package:super_flutter/features/auth/presentation/change_password/screen/change_password_screen.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';

class _Source extends Mock implements AuthRemoteDataSource {}

class _PasswordChanged extends Mock implements PasswordChanged {}

class _Logout extends Mock implements Logout {}

class _AuthCubit extends MockCubit<AuthState> implements AuthCubit {}

const _mustChange = User(
  id: 'u1',
  name: 'Emily',
  email: 'e@test.com',
  passwordChangeRequired: true,
);

void main() {
  late _Source source;
  late _PasswordChanged passwordChanged;
  late _Logout logout;
  late _AuthCubit auth;

  setUp(() async {
    source = _Source();
    passwordChanged = _PasswordChanged();
    logout = _Logout();
    auth = _AuthCubit();
    when(() => passwordChanged()).thenAnswer((_) async {});
    when(() => logout()).thenAnswer((_) async {});
    await getIt.reset();
    getIt.registerFactory<ChangePasswordBloc>(
      () => ChangePasswordBloc(source, passwordChanged, logout),
    );
  });

  void answer(Future<bool> Function() result) => when(
    () => source.changePassword(
      currentPassword: any(named: 'currentPassword'),
      password: any(named: 'password'),
      passwordConfirmation: any(named: 'passwordConfirmation'),
    ),
  ).thenAnswer((_) => result());

  Future<void> pump(WidgetTester tester, {required bool forced}) async {
    when(() => auth.state).thenReturn(
      AuthState(
        status: AuthStatus.authenticated,
        user: forced ? _mustChange : null,
      ),
    );
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: forced ? '/change' : '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/change'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/change',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(
          theme: AppTheme.dark(Flavor.development),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (!forced) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }
  }

  Future<void> fill(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old-pass');
    await tester.enterText(fields.at(1), 'New-pass-123');
    await tester.enterText(fields.at(2), 'New-pass-123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'forced: explained, no way back but sign out; success lets the session go on',
    (tester) async {
      answer(() async => true);
      await pump(tester, forced: true);

      expect(find.text('Set a new password to continue.'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.text('Current password *'), findsOneWidget);
      expect(find.text('New password *'), findsOneWidget);
      expect(find.text('Confirm new password *'), findsOneWidget);

      await fill(tester);
      verify(
        () => source.changePassword(
          currentPassword: 'old-pass',
          password: 'New-pass-123',
          passwordConfirmation: 'New-pass-123',
        ),
      ).called(1);
      verify(() => passwordChanged()).called(1);
      // Nothing to pop: still here until the router moves on.
      expect(find.byType(ChangePasswordScreen), findsOneWidget);

      await tester.tap(find.text('Sign out'));
      await tester.pump();
      verify(() => logout()).called(1);
      await tester.pump(const Duration(seconds: 4));
    },
  );

  testWidgets('opened on purpose: back is there, success pops', (tester) async {
    answer(() async => true);
    await pump(tester, forced: false);

    expect(find.text('Set a new password to continue.'), findsNothing);
    expect(find.text('Sign out'), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    await fill(tester);
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('a wrong current password shows under it', (tester) async {
    const wrong = 'The current password is incorrect.';
    answer(
      () async => throw const ValidationException(
        wrong,
        fieldErrors: {'current_password': wrong},
      ),
    );
    await pump(tester, forced: true);

    await fill(tester);
    expect(find.text(wrong), findsOneWidget);
    verifyNever(() => passwordChanged());
  });
}
