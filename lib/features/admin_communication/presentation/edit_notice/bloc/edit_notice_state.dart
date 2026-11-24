import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/admin_communication/model/priority_model.dart';
import 'package:super_flutter/data/support/model/category_model.dart';

enum EditNoticeStatus { initial, submitting, success, failure }

class EditNoticeState extends Equatable {
  const EditNoticeState({
    this.status = EditNoticeStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.categoryOptions = const [],
    this.priorityOptions = const [],
    this.loadingOptions = false,
  });

  final EditNoticeStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for category_id, loaded when the screen opens.
  final List<CategoryModel> categoryOptions;

  /// The choices for priority, loaded when the screen opens.
  final List<PriorityModel> priorityOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  String? get categoryIdError => fieldErrors['category_id'];
  String? get titleError => fieldErrors['title'];
  String? get bodyError => fieldErrors['body'];
  String? get priorityError => fieldErrors['priority'];
  String? get expiresOnError => fieldErrors['expires_on'];

  bool get isSubmitting => status == EditNoticeStatus.submitting;

  EditNoticeState copyWith({
    EditNoticeStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<CategoryModel>? categoryOptions,
    List<PriorityModel>? priorityOptions,
    bool? loadingOptions,
  }) {
    return EditNoticeState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      categoryOptions: categoryOptions ?? this.categoryOptions,
      priorityOptions: priorityOptions ?? this.priorityOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    categoryOptions,
    priorityOptions,
    loadingOptions,
  ];
}
