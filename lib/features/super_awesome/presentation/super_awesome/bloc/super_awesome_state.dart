import 'package:equatable/equatable.dart';

enum SuperAwesomeStatus { initial, loading, success, failure }

class SuperAwesomeState extends Equatable {
  const SuperAwesomeState({this.status = SuperAwesomeStatus.initial});

  final SuperAwesomeStatus status;

  bool get isLoading => status == SuperAwesomeStatus.loading;

  SuperAwesomeState copyWith({SuperAwesomeStatus? status}) {
    return SuperAwesomeState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
