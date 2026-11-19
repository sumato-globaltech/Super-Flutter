import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.passwordChangeRequired = false,
    this.fieldErrors = const {},
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;
  final bool passwordChangeRequired;
  final Map<String, String> fieldErrors;

  String? get emailError => fieldErrors['email'];

  String? get passwordError => fieldErrors['password'];

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get isValid => email.trim().isNotEmpty && password.isNotEmpty;

  bool get canSubmit => isValid && !isSubmitting;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    bool? passwordChangeRequired,
    Map<String, String>? fieldErrors,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      passwordChangeRequired:
          passwordChangeRequired ?? this.passwordChangeRequired,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    obscurePassword,
    status,
    errorMessage,
    passwordChangeRequired,
    fieldErrors,
  ];
}
