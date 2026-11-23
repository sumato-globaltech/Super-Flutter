import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/domain/auth/use_cases/login.dart';
import 'package:super_flutter/domain/auth/use_cases/request_otp.dart';
import 'package:super_flutter/domain/auth/use_cases/verify_otp.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_bloc.dart';
import 'package:super_flutter/features/auth/presentation/login/bloc/login_state.dart';
import 'package:super_flutter/features/auth/presentation/login/screen/login_screen.dart';

class MockLogin extends Mock implements Login {}

class MockRequestOtp extends Mock implements RequestOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

const _wrong = 'The OTP is invalid or has expired.';

void main() {
  late MockRequestOtp requestOtp;
  late MockVerifyOtp verifyOtp;
  late LoginBloc bloc;

  setUp(() {
    requestOtp = MockRequestOtp();
    verifyOtp = MockVerifyOtp();
    when(() => requestOtp(phone: any(named: 'phone')))
        .thenAnswer((_) async => 3);
  });

  Future<void> pump(WidgetTester tester) async {
    // Made in the test's zone, so its stream follows the test's clock.
    bloc = LoginBloc(MockLogin(), requestOtp, verifyOtp);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(value: bloc, child: const LoginView()),
      ),
    );
    await tester.tap(find.text('Phone'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('phone, code, countdown, resend', (tester) async {
    await pump(tester);
    expect(find.text('Send OTP'), findsOneWidget);

    // A short number is refused before anything is sent.
    await tester.enterText(find.byType(TextFormField), '98765');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
    verifyNever(() => requestOtp(phone: any(named: 'phone')));

    // Letters cannot be typed, and the number stops at ten digits.
    await tester.enterText(find.byType(TextFormField), '98765abc432109999');
    expect(find.text('9876543210'), findsOneWidget);

    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    await tester.pump();
    verify(() => requestOtp(phone: '9876543210')).called(1);
    expect(find.text('We sent a code to 9876543210'), findsOneWidget);
    expect(find.text('Code expires in 0:03'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend OTP'))
          .onPressed,
      isNull,
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Code expires in 0:02'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('The code has expired'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Verify'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Resend OTP'));
    await tester.pump();
    await tester.pump();
    verify(() => requestOtp(phone: '9876543210')).called(1);
    expect(find.text('Code expires in 0:03'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a wrong code shows under the code and clears when edited', (
    tester,
  ) async {
    when(
      () => verifyOtp(
        phone: any(named: 'phone'),
        otp: any(named: 'otp'),
      ),
    ).thenThrow(
      const ValidationException(_wrong, fieldErrors: {'otp': _wrong}),
    );
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    await tester.pump();

    final code = find.byType(TextFormField);
    await tester.enterText(code, '12');
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(find.text('Enter the 6-digit code'), findsOneWidget);

    await tester.enterText(code, '000000');
    await tester.tap(find.text('Verify'));
    await tester.pump();
    await tester.pump();
    verify(() => verifyOtp(phone: '9876543210', otp: '000000')).called(1);
    expect(find.text(_wrong), findsOneWidget);

    await tester.enterText(code, '00000');
    await tester.pump();
    expect(find.text(_wrong), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('a right code signs in; change number goes back', (tester) async {
    when(
      () => verifyOtp(
        phone: any(named: 'phone'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer(
      (_) async => const AuthSession(
        user: User(id: 'u1', name: 'Ramesh', email: ''),
        tokens: AuthTokens(accessToken: 'a'),
      ),
    );
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Change number'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Send OTP'), findsOneWidget);
    expect(bloc.state.otpSent, isFalse);

    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pump();
    await tester.pump();
    expect(bloc.state.status, LoginStatus.success);

    // Email is still there, as it was.
    await tester.tap(find.text('Email'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Login'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
