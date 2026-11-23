import 'package:equatable/equatable.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.obscureCurrentPassword = true,
    this.obscurePassword = true,
    this.obscurePasswordConfirmation = true,
  });

  final ChangePasswordStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;
  final bool obscureCurrentPassword;
  final bool obscurePassword;
  final bool obscurePasswordConfirmation;

  String? get currentPasswordError => fieldErrors['current_password'];
  String? get passwordError => fieldErrors['password'];
  String? get passwordConfirmationError => fieldErrors['password_confirmation'];

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool? obscureCurrentPassword,
    bool? obscurePassword,
    bool? obscurePasswordConfirmation,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      obscureCurrentPassword:
          obscureCurrentPassword ?? this.obscureCurrentPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscurePasswordConfirmation:
          obscurePasswordConfirmation ?? this.obscurePasswordConfirmation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    obscureCurrentPassword,
    obscurePassword,
    obscurePasswordConfirmation,
  ];
}
