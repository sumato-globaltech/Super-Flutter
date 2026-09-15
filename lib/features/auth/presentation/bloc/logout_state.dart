import 'package:equatable/equatable.dart';

enum LogoutStatus { initial, submitting, success, failure }

class LogoutState extends Equatable {
  const LogoutState({this.status = LogoutStatus.initial, this.errorMessage});

  final LogoutStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == LogoutStatus.submitting;

  LogoutState copyWith({LogoutStatus? status, String? errorMessage}) {
    return LogoutState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
