import 'package:equatable/equatable.dart';

class CropModel extends Equatable {
  final String? id;
  final String? name;
  final String? slug;
  final String? scientificName;
  final Map<String, dynamic>? localNames;
  final CropTypeModel? type;
  final String? icon;
  final int? durationDays;
  final UnitModel? defaultUnit;
  final String? summary;
  final List<CropVarietyModel>? varieties;

  const CropModel({
    this.id,
    this.name,
    this.slug,
    this.scientificName,
    this.localNames,
    this.type,
    this.icon,
    this.durationDays,
    this.defaultUnit,
    this.summary,
    this.varieties,
  });

  String? get localName {
    if (localNames == null) return null;
    final other = localNames!['other'];
    if (other is List && other.isNotEmpty) {
      return other.first.toString();
    }
    if (localNames!['hi'] != null) {
      return localNames!['hi'].toString();
    }
    return null;
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      scientificName: json['scientific_name'] as String?,
      localNames: json['local_names'] is Map
          ? Map<String, dynamic>.from(json['local_names'] as Map)
          : null,
      type: json['type'] != null && json['type'] is Map
          ? CropTypeModel.fromJson(
              Map<String, dynamic>.from(json['type'] as Map),
            )
          : null,
      icon: json['icon'] as String?,
      durationDays: json['duration_days'] is int
          ? json['duration_days'] as int
          : int.tryParse('${json['duration_days']}'),
      defaultUnit: json['default_unit'] != null && json['default_unit'] is Map
          ? UnitModel.fromJson(
              Map<String, dynamic>.from(json['default_unit'] as Map),
            )
          : null,
      summary: json['summary'] as String?,
      varieties: json['varieties'] is List
          ? (json['varieties'] as List)
                .whereType<Map>()
                .map(
                  (e) =>
                      CropVarietyModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['scientific_name'] = scientificName;
    data['local_names'] = localNames;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['icon'] = icon;
    data['duration_days'] = durationDays;
    if (defaultUnit != null) {
      data['default_unit'] = defaultUnit!.toJson();
    }
    data['summary'] = summary;
    if (varieties != null) {
      data['varieties'] = varieties!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    scientificName,
    localNames,
    type,
    icon,
    durationDays,
    defaultUnit,
    summary,
    varieties,
  ];
}

class CropTypeModel extends Equatable {
  final String? id;
  final String? name;
  final String? slug;

  const CropTypeModel({this.id, this.name, this.slug});

  factory CropTypeModel.fromJson(Map<String, dynamic> json) {
    return CropTypeModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  @override
  List<Object?> get props => [id, name, slug];
}

class UnitModel extends Equatable {
  final String? id;
  final String? code;
  final String? name;

  const UnitModel({this.id, this.code, this.name});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'name': name};

  @override
  List<Object?> get props => [id, code, name];
}

class CropVarietyModel extends Equatable {
  final String? name;
  final String? type;
  final int? durationDays;
  final dynamic yieldPerHa;
  final String? tolerance;
  final String? elevationBand;
  final List<DistrictModel>? recommendedDistricts;

  const CropVarietyModel({
    this.name,
    this.type,
    this.durationDays,
    this.yieldPerHa,
    this.tolerance,
    this.elevationBand,
    this.recommendedDistricts,
  });

  factory CropVarietyModel.fromJson(Map<String, dynamic> json) {
    return CropVarietyModel(
      name: json['name'] as String?,
      type: json['type'] as String?,
      durationDays: json['duration_days'] is int
          ? json['duration_days'] as int
          : int.tryParse('${json['duration_days']}'),
      yieldPerHa: json['yield_per_ha'],
      tolerance: json['tolerance'] as String?,
      elevationBand: json['elevation_band'] as String?,
      recommendedDistricts: json['recommended_districts'] is List
          ? (json['recommended_districts'] as List)
                .whereType<Map>()
                .map(
                  (e) => DistrictModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'duration_days': durationDays,
      'yield_per_ha': yieldPerHa,
      'tolerance': tolerance,
      'elevation_band': elevationBand,
      if (recommendedDistricts != null)
        'recommended_districts': recommendedDistricts!
            .map((e) => e.toJson())
            .toList(),
    };
  }

  @override
  List<Object?> get props => [
    name,
    type,
    durationDays,
    yieldPerHa,
    tolerance,
    elevationBand,
    recommendedDistricts,
  ];
}

class DistrictModel extends Equatable {
  final String? id;
  final String? name;

  const DistrictModel({this.id, this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}
