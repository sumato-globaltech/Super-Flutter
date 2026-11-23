import 'package:equatable/equatable.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class ChangePasswordStarted extends ChangePasswordEvent {
  const ChangePasswordStarted();
}

class ChangePasswordCurrentPasswordVisibilityToggled
    extends ChangePasswordEvent {
  const ChangePasswordCurrentPasswordVisibilityToggled();
}

class ChangePasswordPasswordVisibilityToggled extends ChangePasswordEvent {
  const ChangePasswordPasswordVisibilityToggled();
}

class ChangePasswordPasswordConfirmationVisibilityToggled
    extends ChangePasswordEvent {
  const ChangePasswordPasswordConfirmationVisibilityToggled();
}

class ChangePasswordFieldErrorCleared extends ChangePasswordEvent {
  const ChangePasswordFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];

  @override
  String toString() =>
      'ChangePasswordSubmitted(currentPassword: ***, password: ***, passwordConfirmation: ***)';
}

/// Leaves instead of changing the password.
class ChangePasswordSignOutRequested extends ChangePasswordEvent {
  const ChangePasswordSignOutRequested();
}
