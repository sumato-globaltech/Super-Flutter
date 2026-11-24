import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/schemes/model/scheme_application_model.dart';
import 'package:super_flutter/data/schemes/model/scheme_model.dart';

enum SchemeDetailStatus { initial, loading, success, failure }

class SchemeDetailState extends Equatable {
  const SchemeDetailState({
    this.status = SchemeDetailStatus.initial,
    this.schemeDetails,
    this.errorMessage,
    this.farmer = false,
    this.application,
  });

  final SchemeDetailStatus status;
  final SchemeModel? schemeDetails;
  final String? errorMessage;
  final bool farmer;

  /// The farmer's own application to this scheme, when there is one.
  final SchemeApplicationModel? application;

  bool get canApply =>
      farmer && application == null && (schemeDetails?.isOpen ?? false);

  SchemeDetailState copyWith({
    SchemeDetailStatus? status,
    SchemeModel? schemeDetails,
    String? errorMessage,
    bool? farmer,
    SchemeApplicationModel? application,
  }) {
    return SchemeDetailState(
      status: status ?? this.status,
      schemeDetails: schemeDetails ?? this.schemeDetails,
      errorMessage: errorMessage,
      farmer: farmer ?? this.farmer,
      application: application ?? this.application,
    );
  }

  @override
  List<Object?> get props => [
    status,
    schemeDetails,
    errorMessage,
    farmer,
    application,
  ];
}
