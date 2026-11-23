import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

enum LoginMethod { email, phone }

class LoginState extends Equatable {
  const LoginState({
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.passwordChangeRequired = false,
    this.fieldErrors = const {},
    this.method = LoginMethod.email,
    this.otpPhone,
    this.otpSecondsLeft = 0,
  });

  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;
  final bool passwordChangeRequired;
  final Map<String, String> fieldErrors;
  final LoginMethod method;

  /// The number the code was sent to; null until one is sent.
  final String? otpPhone;
  final int otpSecondsLeft;

  String? get emailError => fieldErrors['email'];

  String? get passwordError => fieldErrors['password'];

  String? get phoneError => fieldErrors['phone'];

  String? get otpError => fieldErrors['otp'];

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get otpSent => otpPhone != null;

  bool get otpExpired => otpSent && otpSecondsLeft == 0;

  LoginState copyWith({
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    bool? passwordChangeRequired,
    Map<String, String>? fieldErrors,
    LoginMethod? method,
    String? Function()? otpPhone,
    int? otpSecondsLeft,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      passwordChangeRequired:
          passwordChangeRequired ?? this.passwordChangeRequired,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      method: method ?? this.method,
      otpPhone: otpPhone != null ? otpPhone() : this.otpPhone,
      otpSecondsLeft: otpSecondsLeft ?? this.otpSecondsLeft,
    );
  }

  @override
  List<Object?> get props => [
    obscurePassword,
    status,
    errorMessage,
    passwordChangeRequired,
    fieldErrors,
    method,
    otpPhone,
    otpSecondsLeft,
  ];
}
