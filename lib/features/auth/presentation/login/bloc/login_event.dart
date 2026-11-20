import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginFieldErrorCleared extends LoginEvent {
  const LoginFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];

  @override
  String toString() => 'LoginSubmitted(email: $email, password: ***)';
}
