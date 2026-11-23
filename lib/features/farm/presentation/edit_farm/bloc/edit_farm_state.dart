import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/block_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/irrigation_type_model.dart';
import 'package:super_flutter/data/farm/model/ownership_model.dart';
import 'package:super_flutter/data/farm/model/soil_type_model.dart';

enum EditFarmStatus { initial, submitting, success, failure }

class EditFarmState extends Equatable {
  const EditFarmState({
    this.status = EditFarmStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
    this.blockOptions = const [],
    this.soilTypeOptions = const [],
    this.irrigationTypeOptions = const [],
    this.ownershipOptions = const [],
    this.loadingOptions = false,
    this.farm,
  });

  final EditFarmStatus status;
  final String? errorMessage;

  /// Errors the server reported, keyed by the API's field name.
  final Map<String, String> fieldErrors;

  /// The choices for block_id, loaded when the screen opens.
  final List<BlockModel> blockOptions;

  /// The choices for soil_type, loaded when the screen opens.
  final List<SoilTypeModel> soilTypeOptions;

  /// The choices for irrigation_type, loaded when the screen opens.
  final List<IrrigationTypeModel> irrigationTypeOptions;

  /// The choices for ownership, loaded when the screen opens.
  final List<OwnershipModel> ownershipOptions;

  /// Whether the dropdowns' choices are still loading.
  final bool loadingOptions;

  final FarmModel? farm;

  String? get nameError => fieldErrors['name'];
  String? get areaHaError => fieldErrors['area_ha'];
  String? get blockIdError => fieldErrors['block_id'];
  String? get villageError => fieldErrors['village'];
  String? get addressError => fieldErrors['address'];
  String? get soilTypeError => fieldErrors['soil_type'];
  String? get irrigationTypeError => fieldErrors['irrigation_type'];
  String? get ownershipError => fieldErrors['ownership'];
  String? get latitudeError => fieldErrors['latitude'];
  String? get longitudeError => fieldErrors['longitude'];

  bool get isSubmitting => status == EditFarmStatus.submitting;

  EditFarmState copyWith({
    EditFarmStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    List<BlockModel>? blockOptions,
    List<SoilTypeModel>? soilTypeOptions,
    List<IrrigationTypeModel>? irrigationTypeOptions,
    List<OwnershipModel>? ownershipOptions,
    bool? loadingOptions,
    FarmModel? farm,
  }) {
    return EditFarmState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      blockOptions: blockOptions ?? this.blockOptions,
      soilTypeOptions: soilTypeOptions ?? this.soilTypeOptions,
      irrigationTypeOptions:
          irrigationTypeOptions ?? this.irrigationTypeOptions,
      ownershipOptions: ownershipOptions ?? this.ownershipOptions,
      loadingOptions: loadingOptions ?? this.loadingOptions,
      farm: farm ?? this.farm,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    blockOptions,
    soilTypeOptions,
    irrigationTypeOptions,
    ownershipOptions,
    loadingOptions,
    farm,
  ];
}
