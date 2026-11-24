import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

enum CreateTicketStatus { initial, submitting, success, failure }

class CreateTicketState extends Equatable {
  const CreateTicketState({
    this.status = CreateTicketStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.categoryOptions = const [],
    this.cropOptions = const [],
    this.loadingOptions = false,
  });

  final CreateTicketStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for category_id, loaded when the screen opens.
  final List<CategoryModel> categoryOptions;

  /// The choices for crop_id, loaded when the screen opens.
  final List<CropModel> cropOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  String? get categoryIdError => fieldErrors['category_id'];
  String? get subjectError => fieldErrors['subject'];
  String? get questionError => fieldErrors['question'];
  String? get cropIdError => fieldErrors['crop_id'];
  String? get photoError => fieldErrors['photo'];

  bool get isSubmitting => status == CreateTicketStatus.submitting;

  CreateTicketState copyWith({
    CreateTicketStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<CategoryModel>? categoryOptions,
    List<CropModel>? cropOptions,
    bool? loadingOptions,
  }) {
    return CreateTicketState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      cropOptions: cropOptions ?? this.cropOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    categoryOptions,
    cropOptions,
    loadingOptions,
  ];
}
