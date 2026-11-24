import 'package:equatable/equatable.dart';

enum MyApplicationsStatus { initial, loading, success, failure }

class MyApplicationsState extends Equatable {
  const MyApplicationsState({this.status = MyApplicationsStatus.initial});

  final MyApplicationsStatus status;

  bool get isLoading => status == MyApplicationsStatus.loading;

  MyApplicationsState copyWith({MyApplicationsStatus? status}) {
    return MyApplicationsState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
