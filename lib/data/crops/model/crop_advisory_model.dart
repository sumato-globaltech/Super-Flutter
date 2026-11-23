import 'package:equatable/equatable.dart';
import 'crop_model.dart';

class CropAdvisoryModel extends Equatable {
  final CropModel? crop;
  final DistrictModel? district;
  final MonthModel? month;
  final WindowsModel? windows;
  final CropProfileModel? profile;
  final List<CropPracticeModel>? practices;
  final List<CropFertilizerGroupModel>? fertilizers;
  final List<CropVarietyModel>? varieties;
  final Map<String, dynamic>? economics;

  const CropAdvisoryModel({
    this.crop,
    this.district,
    this.month,
    this.windows,
    this.profile,
    this.practices,
    this.fertilizers,
    this.varieties,
    this.economics,
  });

  factory CropAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return CropAdvisoryModel(
      crop: json['crop'] is Map
          ? CropModel.fromJson(Map<String, dynamic>.from(json['crop'] as Map))
          : null,
      district: json['district'] is Map
          ? DistrictModel.fromJson(
              Map<String, dynamic>.from(json['district'] as Map),
            )
          : null,
      month: json['month'] is Map
          ? MonthModel.fromJson(Map<String, dynamic>.from(json['month'] as Map))
          : null,
      windows: json['windows'] is Map
          ? WindowsModel.fromJson(
              Map<String, dynamic>.from(json['windows'] as Map),
            )
          : null,
      profile: json['profile'] is Map
          ? CropProfileModel.fromJson(
              Map<String, dynamic>.from(json['profile'] as Map),
            )
          : null,
      practices: json['practices'] is List
          ? (json['practices'] as List)
              .whereType<Map>()
              .map((e) =>
                  CropPracticeModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      fertilizers: json['fertilizers'] is List
          ? (json['fertilizers'] as List)
              .whereType<Map>()
              .map((e) =>
                  CropFertilizerGroupModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      varieties: json['varieties'] is List
          ? (json['varieties'] as List)
              .whereType<Map>()
              .map((e) =>
                  CropVarietyModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      economics: json['economics'] is Map
          ? Map<String, dynamic>.from(json['economics'] as Map)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        crop,
        district,
        month,
        windows,
        profile,
        practices,
        fertilizers,
        varieties,
        economics,
      ];
}

class MonthModel extends Equatable {
  final int? number;
  final String? name;

  const MonthModel({this.number, this.name});

  factory MonthModel.fromJson(Map<String, dynamic> json) {
    return MonthModel(
      number: json['number'] is int
          ? json['number'] as int
          : int.tryParse('${json['number']}'),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'number': number, 'name': name};

  @override
  List<Object?> get props => [number, name];
}

class WindowsModel extends Equatable {
  final String? sowing;
  final String? harvest;

  const WindowsModel({this.sowing, this.harvest});

  factory WindowsModel.fromJson(Map<String, dynamic> json) {
    return WindowsModel(
      sowing: json['sowing']?.toString(),
      harvest: json['harvest']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'sowing': sowing, 'harvest': harvest};

  @override
  List<Object?> get props => [sowing, harvest];
}

class CropProfileModel extends Equatable {
  final CropClimateModel? climate;
  final CropSoilModel? soil;
  final CropSowingModel? sowing;
  final CropFieldPracticesModel? fieldPractices;

  const CropProfileModel({
    this.climate,
    this.soil,
    this.sowing,
    this.fieldPractices,
  });

  factory CropProfileModel.fromJson(Map<String, dynamic> json) {
    return CropProfileModel(
      climate: json['climate'] is Map
          ? CropClimateModel.fromJson(
              Map<String, dynamic>.from(json['climate'] as Map),
            )
          : null,
      soil: json['soil'] is Map
          ? CropSoilModel.fromJson(
              Map<String, dynamic>.from(json['soil'] as Map),
            )
          : null,
      sowing: json['sowing'] is Map
          ? CropSowingModel.fromJson(
              Map<String, dynamic>.from(json['sowing'] as Map),
            )
          : null,
      fieldPractices: json['field_practices'] is Map
          ? CropFieldPracticesModel.fromJson(
              Map<String, dynamic>.from(json['field_practices'] as Map),
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [climate, soil, sowing, fieldPractices];
}

class CropClimateModel extends Equatable {
  final dynamic tempMinC;
  final dynamic tempMaxC;
  final dynamic rainMinMm;
  final dynamic rainMaxMm;

  const CropClimateModel({
    this.tempMinC,
    this.tempMaxC,
    this.rainMinMm,
    this.rainMaxMm,
  });

  factory CropClimateModel.fromJson(Map<String, dynamic> json) {
    return CropClimateModel(
      tempMinC: json['temp_min_c'],
      tempMaxC: json['temp_max_c'],
      rainMinMm: json['rain_min_mm'],
      rainMaxMm: json['rain_max_mm'],
    );
  }

  @override
  List<Object?> get props => [tempMinC, tempMaxC, rainMinMm, rainMaxMm];
}

class CropSoilModel extends Equatable {
  final List<String> types;
  final dynamic phMin;
  final dynamic phMax;
  final String? drainage;
  final String? organicMatter;
  final String? saltTolerance;

  const CropSoilModel({
    this.types = const [],
    this.phMin,
    this.phMax,
    this.drainage,
    this.organicMatter,
    this.saltTolerance,
  });

  factory CropSoilModel.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];
    final parsedTypes = rawTypes is List
        ? rawTypes.map((e) => e.toString()).toList()
        : <String>[];
    return CropSoilModel(
      types: parsedTypes,
      phMin: json['ph_min'],
      phMax: json['ph_max'],
      drainage: json['drainage'] as String?,
      organicMatter: json['organic_matter'] as String?,
      saltTolerance: json['salt_tolerance'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        types,
        phMin,
        phMax,
        drainage,
        organicMatter,
        saltTolerance,
      ];
}

class CropSowingModel extends Equatable {
  final String? method;
  final dynamic seedRateKgHa;
  final dynamic plantingDepthCm;
  final String? spacing;

  const CropSowingModel({
    this.method,
    this.seedRateKgHa,
    this.plantingDepthCm,
    this.spacing,
  });

  factory CropSowingModel.fromJson(Map<String, dynamic> json) {
    return CropSowingModel(
      method: json['method'] as String?,
      seedRateKgHa: json['seed_rate_kg_ha'],
      plantingDepthCm: json['planting_depth_cm'],
      spacing: json['spacing']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        method,
        seedRateKgHa,
        plantingDepthCm,
        spacing,
      ];
}

class CropFieldPracticesModel extends Equatable {
  final String? landPreparation;
  final String? interculturalOperations;
  final String? weedManagement;
  final String? mulching;
  final String? labourRequirement;

  const CropFieldPracticesModel({
    this.landPreparation,
    this.interculturalOperations,
    this.weedManagement,
    this.mulching,
    this.labourRequirement,
  });

  factory CropFieldPracticesModel.fromJson(Map<String, dynamic> json) {
    return CropFieldPracticesModel(
      landPreparation: json['land_preparation'] as String?,
      interculturalOperations: json['intercultural_operations'] as String?,
      weedManagement: json['weed_management'] as String?,
      mulching: json['mulching'] as String?,
      labourRequirement: json['labour_requirement'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        landPreparation,
        interculturalOperations,
        weedManagement,
        mulching,
        labourRequirement,
      ];
}

class CropPracticeModel extends Equatable {
  final String? kind;
  final String? label;
  final List<String> steps;

  const CropPracticeModel({
    this.kind,
    this.label,
    this.steps = const [],
  });

  factory CropPracticeModel.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final parsedSteps = rawSteps is List
        ? rawSteps.map((e) => e.toString()).toList()
        : <String>[];
    return CropPracticeModel(
      kind: json['kind'] as String?,
      label: json['label'] as String?,
      steps: parsedSteps,
    );
  }

  @override
  List<Object?> get props => [kind, label, steps];
}

class CropFertilizerGroupModel extends Equatable {
  final String? recommendation;
  final String? label;
  final List<CropFertilizerItemModel> items;

  const CropFertilizerGroupModel({
    this.recommendation,
    this.label,
    this.items = const [],
  });

  factory CropFertilizerGroupModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => CropFertilizerItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <CropFertilizerItemModel>[];
    return CropFertilizerGroupModel(
      recommendation: json['recommendation'] as String?,
      label: json['label'] as String?,
      items: parsedItems,
    );
  }

  @override
  List<Object?> get props => [recommendation, label, items];
}

class CropFertilizerItemModel extends Equatable {
  final String? fertilizer;
  final String? composition;
  final dynamic dosage;
  final String? stage;
  final int? priority;
  final String? notes;

  const CropFertilizerItemModel({
    this.fertilizer,
    this.composition,
    this.dosage,
    this.stage,
    this.priority,
    this.notes,
  });

  factory CropFertilizerItemModel.fromJson(Map<String, dynamic> json) {
    return CropFertilizerItemModel(
      fertilizer: json['fertilizer'] as String?,
      composition: json['composition']?.toString(),
      dosage: json['dosage'],
      stage: json['stage']?.toString(),
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse('${json['priority']}'),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        fertilizer,
        composition,
        dosage,
        stage,
        priority,
        notes,
      ];
}
