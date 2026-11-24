import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/admin_communication/model/district_model.dart';
import 'package:super_flutter/data/admin_communication/model/severity_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

enum AddAlertStatus { initial, submitting, success, failure }

class AddAlertState extends Equatable {
  const AddAlertState({
    this.status = AddAlertStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.categoryOptions = const [],
    this.districtOptions = const [],
    this.severityOptions = const [],
    this.loadingOptions = false,
  });

  final AddAlertStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for category_id, loaded when the screen opens.
  final List<CategoryModel> categoryOptions;

  /// The choices for district_id, loaded when the screen opens.
  final List<DistrictModel> districtOptions;

  /// The choices for severity, loaded when the screen opens.
  final List<SeverityModel> severityOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  String? get categoryIdError => fieldErrors['category_id'];
  String? get districtIdError => fieldErrors['district_id'];
  String? get titleError => fieldErrors['title'];
  String? get descriptionError => fieldErrors['description'];
  String? get severityError => fieldErrors['severity'];
  String? get startsOnError => fieldErrors['starts_on'];
  String? get endsOnError => fieldErrors['ends_on'];

  bool get isSubmitting => status == AddAlertStatus.submitting;

  AddAlertState copyWith({
    AddAlertStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<CategoryModel>? categoryOptions,
    List<DistrictModel>? districtOptions,
    List<SeverityModel>? severityOptions,
    bool? loadingOptions,
  }) {
    return AddAlertState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      districtOptions: districtOptions ?? this.districtOptions,
      severityOptions: severityOptions ?? this.severityOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    categoryOptions,
    districtOptions,
    severityOptions,
    loadingOptions,
  ];
}
