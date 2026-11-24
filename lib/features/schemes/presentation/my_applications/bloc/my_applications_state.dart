import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/model/scheme_application_model.dart';

enum MyApplicationsStatus { initial, loading, success, failure }

class MyApplicationsState extends Equatable {
  const MyApplicationsState({
    this.status = MyApplicationsStatus.initial,
    this.applications,
    this.loadingMore = false,
    this.errorMessage,
  });

  final MyApplicationsStatus status;
  final Paged<SchemeApplicationModel>? applications;
  final bool loadingMore;
  final String? errorMessage;

  MyApplicationsState copyWith({
    MyApplicationsStatus? status,
    Paged<SchemeApplicationModel>? applications,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return MyApplicationsState(
      status: status ?? this.status,
      applications: applications ?? this.applications,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, applications, loadingMore, errorMessage];
}
