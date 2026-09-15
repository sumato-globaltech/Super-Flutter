import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String username;
  final String password;
  final LoginStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get isValid => username.trim().isNotEmpty && password.isNotEmpty;

  bool get canSubmit => isValid && !isSubmitting;

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, password, status, errorMessage];
}
