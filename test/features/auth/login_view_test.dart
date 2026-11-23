import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/domain/auth/use_cases/request_otp.dart';
import 'package:super_flutter/domain/auth/use_cases/verify_otp.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:super_flutter/features/auth/presentation/login/screen/login_screen.dart';

class MockLogin extends Mock implements Login {}

class MockRequestOtp extends Mock implements RequestOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

void main() {
  const serverError = 'These credentials do not match our records.';

  testWidgets('can submit again after a server field error', (tester) async {
    final login = MockLogin();
    when(
      () => login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const ValidationException(
        serverError,
        fieldErrors: {'email': serverError},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => LoginBloc(login, MockRequestOtp(), MockVerifyOtp()),
          child: const LoginView(),
        ),
      ),
    );

    final email = find.byType(TextFormField).at(0);
    final password = find.byType(TextFormField).at(1);
    await tester.enterText(email, 'user@test.com');
    await tester.enterText(password, 'wrong');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text(serverError), findsOneWidget);

    await tester.enterText(email, 'user@test.co');
    await tester.pumpAndSettle();
    expect(find.text(serverError), findsNothing);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    verify(
      () => login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(2);
  });
}
