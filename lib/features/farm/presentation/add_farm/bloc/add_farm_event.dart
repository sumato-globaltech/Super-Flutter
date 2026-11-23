import 'package:equatable/equatable.dart';

sealed class AddFarmEvent extends Equatable {
  const AddFarmEvent();

  @override
  List<Object?> get props => [];
}

class AddFarmStarted extends AddFarmEvent {
  const AddFarmStarted();
}

class AddFarmFieldErrorCleared extends AddFarmEvent {
  const AddFarmFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class AddFarmSubmitted extends AddFarmEvent {
  const AddFarmSubmitted({
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
