import 'package:equatable/equatable.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.passwordChangeRequired = false,
    this.fieldErrors = const {},
  });

  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;
  final bool passwordChangeRequired;
  final Map<String, String> fieldErrors;

  String? get emailError => fieldErrors['email'];

  String? get passwordError => fieldErrors['password'];

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    bool? passwordChangeRequired,
    Map<String, String>? fieldErrors,
  }) {
    return LoginState(
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
    obscurePassword,
    status,
    errorMessage,
    passwordChangeRequired,
    fieldErrors,
  ];
}
