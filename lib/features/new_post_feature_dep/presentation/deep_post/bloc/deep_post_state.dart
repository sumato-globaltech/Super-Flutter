import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/new_post_feature_dep/model/district_model.dart';

enum DeepPostStatus { initial, submitting, success, failure }

class DeepPostState extends Equatable {
  const DeepPostState({
    this.status = DeepPostStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.districtOptions = const [],
    this.loadingOptions = false,
  });

  final DeepPostStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for district_id, loaded when the screen opens.
  final List<DistrictModel> districtOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  String? get nameError => fieldErrors['name'];
  String? get districtIdError => fieldErrors['district_id'];

  bool get isSubmitting => status == DeepPostStatus.submitting;

  DeepPostState copyWith({
    DeepPostStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<DistrictModel>? districtOptions,
    bool? loadingOptions,
  }) {
    return DeepPostState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      districtOptions: districtOptions ?? this.districtOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    districtOptions,
    loadingOptions,
  ];
}
