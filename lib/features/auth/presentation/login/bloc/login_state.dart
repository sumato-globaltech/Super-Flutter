import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.passwordChangeRequired = false,
  });

  final String username;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;
  final bool passwordChangeRequired;

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get isValid => username.trim().isNotEmpty && password.isNotEmpty;

  bool get canSubmit => isValid && !isSubmitting;

  LoginState copyWith({
    String? username,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    bool? passwordChangeRequired,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      passwordChangeRequired:
          passwordChangeRequired ?? this.passwordChangeRequired,
    );
  }

  @override
  List<Object?> get props => [
    username,
    password,
    obscurePassword,
    status,
    errorMessage,
    passwordChangeRequired,
  ];
}
