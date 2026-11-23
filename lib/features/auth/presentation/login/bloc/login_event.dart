import 'package:equatable/equatable.dart';

import 'login_state.dart';

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

class LoginMethodChanged extends LoginEvent {
  const LoginMethodChanged(this.method);

  final LoginMethod method;

  @override
  List<Object?> get props => [method];
}

/// Sends a code to [phone]; sent again, it is a resend.
class LoginOtpRequested extends LoginEvent {
  const LoginOtpRequested(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class LoginOtpSubmitted extends LoginEvent {
  const LoginOtpSubmitted(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];

  @override
  String toString() => 'LoginOtpSubmitted(otp: ***)';
}

/// Back to the phone number, to send the code elsewhere.
class LoginOtpNumberChanged extends LoginEvent {
  const LoginOtpNumberChanged();
}

class LoginOtpTimerStarted extends LoginEvent {
  const LoginOtpTimerStarted(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}
