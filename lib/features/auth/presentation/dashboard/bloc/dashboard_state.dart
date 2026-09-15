import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, submitting, success, failure }

class DashboardState extends Equatable {
  const DashboardState({this.status = DashboardStatus.initial, this.errorMessage});

  final DashboardStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == DashboardStatus.submitting;

  DashboardState copyWith({DashboardStatus? status, String? errorMessage}) {
    return DashboardState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
