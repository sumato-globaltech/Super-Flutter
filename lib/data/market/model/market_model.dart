import 'package:equatable/equatable.dart';

class MarketModel extends Equatable {
  final String? id;
  final String? name;
  final MarketTypeModel? type;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String>? facilities;
  final DistrictModel? district;
  final double? distanceKm;
  final bool isFavourite;

  const MarketModel({
    this.id,
    this.name,
    this.type,
    this.address,
    this.latitude,
    this.longitude,
    this.facilities,
    this.district,
    this.distanceKm,
    this.isFavourite = false,
  });

  MarketModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        type = json['type'] != null
            ? MarketTypeModel.fromJson(json['type'])
            : null,
        address = json['address'],
        latitude = json['latitude'] != null
            ? double.tryParse(json['latitude'].toString())
            : null,
        longitude = json['longitude'] != null
            ? double.tryParse(json['longitude'].toString())
            : null,
        facilities = json['facilities'] != null
            ? List<String>.from(json['facilities'])
            : null,
        district = json['district'] != null
            ? DistrictModel.fromJson(json['district'])
            : null,
        distanceKm = json['distance_km'] != null
            ? double.tryParse(json['distance_km'].toString())
            : null,
        isFavourite = false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['facilities'] = facilities;
    if (district != null) {
      data['district'] = district!.toJson();
    }
    data['distance_km'] = distanceKm;
    return data;
  }

  MarketModel copyWith({
    String? id,
    String? name,
    MarketTypeModel? type,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? facilities,
    DistrictModel? district,
    double? distanceKm,
    bool? isFavourite,
  }) {
    return MarketModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      facilities: facilities ?? this.facilities,
      district: district ?? this.district,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    address,
    latitude,
    longitude,
    facilities,
    district,
    distanceKm,
    isFavourite,
  ];
}

class MarketTypeModel extends Equatable {
  final String? value;
  final String? label;

  const MarketTypeModel({this.value, this.label});

  MarketTypeModel.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        label = json['label'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }

  @override
  List<Object?> get props => [value, label];
}

class DistrictModel extends Equatable {
  final String? id;
  final String? name;

  const DistrictModel({this.id, this.name});

  DistrictModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }

  @override
  List<Object?> get props => [id, name];
}
