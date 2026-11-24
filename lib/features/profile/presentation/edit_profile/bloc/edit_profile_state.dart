import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/block_model.dart';
import 'package:super_flutter/data/profile/model/gender_model.dart';
import 'package:super_flutter/data/profile/model/land_ownership_model.dart';

enum EditProfileStatus { initial, submitting, success, failure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.genderOptions = const [],
    this.landOwnershipOptions = const [],
    this.blockOptions = const [],
    this.loadingOptions = false,
  });

  final EditProfileStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for gender, loaded when the screen opens.
  final List<GenderModel> genderOptions;

  /// The choices for land_ownership, loaded when the screen opens.
  final List<LandOwnershipModel> landOwnershipOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  /// The blocks of the farmer's districts.
  final List<BlockModel> blockOptions;

  String? get nameError => fieldErrors['name'];
  String? get emailError => fieldErrors['email'];
  String? get genderError => fieldErrors['gender'];
  String? get dateOfBirthError => fieldErrors['date_of_birth'];
  String? get villageError => fieldErrors['village'];
  String? get addressError => fieldErrors['address'];
  String? get landAreaHaError => fieldErrors['land_area_ha'];
  String? get landOwnershipError => fieldErrors['land_ownership'];

  /// `block_ids`, or `block_ids.0` for one of them.
  MapEntry<String, String>? get blockIdsError {
    for (final error in fieldErrors.entries) {
      if (error.key.startsWith('block_ids')) return error;
    }
    return null;
  }

  bool get isSubmitting => status == EditProfileStatus.submitting;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<GenderModel>? genderOptions,
    List<LandOwnershipModel>? landOwnershipOptions,
    List<BlockModel>? blockOptions,
    bool? loadingOptions,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      genderOptions: genderOptions ?? this.genderOptions,
      landOwnershipOptions: landOwnershipOptions ?? this.landOwnershipOptions,
      blockOptions: blockOptions ?? this.blockOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    genderOptions,
    landOwnershipOptions,
    blockOptions,
    loadingOptions,
  ];
}
