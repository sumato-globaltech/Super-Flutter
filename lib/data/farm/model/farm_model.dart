import 'package:equatable/equatable.dart';

class FarmModel extends Equatable {
  final String? id;
  final String? code;
  final String? name;
  final double? areaHa;
  final FarmDistrictModel? district;
  final FarmBlockModel? block;
  final String? village;
  final String? address;
  final double? latitude;
  final double? longitude;
  final ValueLabelModel? soilType;
  final ValueLabelModel? irrigationType;
  final ValueLabelModel? ownership;
  final bool isActive;
  final String? createdAt;

  const FarmModel({
    this.id,
    this.code,
    this.name,
    this.areaHa,
    this.district,
    this.block,
    this.village,
    this.address,
    this.latitude,
    this.longitude,
    this.soilType,
    this.irrigationType,
    this.ownership,
    this.isActive = true,
    this.createdAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      areaHa: json['area_ha'] is num
          ? (json['area_ha'] as num).toDouble()
          : double.tryParse('${json['area_ha']}'),
      district: json['district'] is Map
          ? FarmDistrictModel.fromJson(
              Map<String, dynamic>.from(json['district'] as Map),
            )
          : null,
      block: json['block'] is Map
          ? FarmBlockModel.fromJson(
              Map<String, dynamic>.from(json['block'] as Map),
            )
          : null,
      village: json['village'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse('${json['latitude']}'),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse('${json['longitude']}'),
      soilType: json['soil_type'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['soil_type'] as Map),
            )
          : null,
      irrigationType: json['irrigation_type'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['irrigation_type'] as Map),
            )
          : null,
      ownership: json['ownership'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['ownership'] as Map),
            )
          : null,
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : json['is_active'] == 1 || json['is_active'] == '1',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'area_ha': areaHa,
      if (district != null) 'district': district!.toJson(),
      if (block != null) 'block': block!.toJson(),
      'village': village,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (soilType != null) 'soil_type': soilType!.toJson(),
      if (irrigationType != null) 'irrigation_type': irrigationType!.toJson(),
      if (ownership != null) 'ownership': ownership!.toJson(),
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    areaHa,
    district,
    block,
    village,
    address,
    latitude,
    longitude,
    soilType,
    irrigationType,
    ownership,
    isActive,
    createdAt,
  ];
}

class FarmDistrictModel extends Equatable {
  final String? id;
  final String? name;

  const FarmDistrictModel({this.id, this.name});

  factory FarmDistrictModel.fromJson(Map<String, dynamic> json) {
    return FarmDistrictModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class FarmBlockModel extends Equatable {
  final String? id;
  final String? name;

  const FarmBlockModel({this.id, this.name});

  factory FarmBlockModel.fromJson(Map<String, dynamic> json) {
    return FarmBlockModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class ValueLabelModel extends Equatable {
  final String? value;
  final String? label;

  const ValueLabelModel({this.value, this.label});

  factory ValueLabelModel.fromJson(Map<String, dynamic> json) {
    return ValueLabelModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};

  @override
  List<Object?> get props => [value, label];
}
