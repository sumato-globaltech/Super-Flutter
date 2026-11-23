import 'package:equatable/equatable.dart';

sealed class EditFarmEvent extends Equatable {
  const EditFarmEvent();

  @override
  List<Object?> get props => [];
}

class EditFarmStarted extends EditFarmEvent {
  const EditFarmStarted();
}

class EditFarmFieldErrorCleared extends EditFarmEvent {
  const EditFarmFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class EditFarmSubmitted extends EditFarmEvent {
  const EditFarmSubmitted({
    required this.farm,
    required this.name,
    required this.areaHa,
    this.blockId,
    this.village,
    this.address,
    this.soilType,
    this.irrigationType,
    this.ownership,
    this.latitude,
    this.longitude,
  });

  final String farm;
  final String name;
  final double areaHa;
  final String? blockId;
  final String? village;
  final String? address;
  final String? soilType;
  final String? irrigationType;
  final String? ownership;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [
    farm,
    name,
    areaHa,
    blockId,
    village,
    address,
    soilType,
    irrigationType,
    ownership,
    latitude,
    longitude,
  ];
}
