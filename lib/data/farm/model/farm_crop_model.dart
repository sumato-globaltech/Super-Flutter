import 'package:equatable/equatable.dart';
import 'farm_model.dart';

class FarmCropModel extends Equatable {
  final String? id;
  final FarmCropRefModel? crop;
  final FarmVarietyRefModel? variety;
  final FinancialYearModel? financialYear;
  final ValueLabelModel? season;
  final ValueLabelModel? status;
  final double? areaHa;
  final String? sownOn;
  final String? expectedHarvestOn;
  final String? harvestedOn;
  final String? notes;

  const FarmCropModel({
    this.id,
    this.crop,
    this.variety,
    this.financialYear,
    this.season,
    this.status,
    this.areaHa,
    this.sownOn,
    this.expectedHarvestOn,
    this.harvestedOn,
    this.notes,
  });

  factory FarmCropModel.fromJson(Map<String, dynamic> json) {
    return FarmCropModel(
      id: json['id'] as String?,
      crop: json['crop'] is Map
          ? FarmCropRefModel.fromJson(
              Map<String, dynamic>.from(json['crop'] as Map),
            )
          : null,
      variety: json['variety'] is Map
          ? FarmVarietyRefModel.fromJson(
              Map<String, dynamic>.from(json['variety'] as Map),
            )
          : null,
      financialYear: json['financial_year'] is Map
          ? FinancialYearModel.fromJson(
              Map<String, dynamic>.from(json['financial_year'] as Map),
            )
          : null,
      season: json['season'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['season'] as Map),
            )
          : null,
      status: json['status'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['status'] as Map),
            )
          : null,
      areaHa: json['area_ha'] is num
          ? (json['area_ha'] as num).toDouble()
          : double.tryParse('${json['area_ha']}'),
      sownOn: json['sown_on'] as String?,
      expectedHarvestOn: json['expected_harvest_on'] as String?,
      harvestedOn: json['harvested_on'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (crop != null) 'crop': crop!.toJson(),
      if (variety != null) 'variety': variety!.toJson(),
      if (financialYear != null) 'financial_year': financialYear!.toJson(),
      if (season != null) 'season': season!.toJson(),
      if (status != null) 'status': status!.toJson(),
      'area_ha': areaHa,
      'sown_on': sownOn,
      'expected_harvest_on': expectedHarvestOn,
      'harvested_on': harvestedOn,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        crop,
        variety,
        financialYear,
        season,
        status,
        areaHa,
        sownOn,
        expectedHarvestOn,
        harvestedOn,
        notes,
      ];
}

class FarmCropRefModel extends Equatable {
  final String? id;
  final String? name;
  final String? slug;

  const FarmCropRefModel({this.id, this.name, this.slug});

  factory FarmCropRefModel.fromJson(Map<String, dynamic> json) {
    return FarmCropRefModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  @override
  List<Object?> get props => [id, name, slug];
}

class FarmVarietyRefModel extends Equatable {
  final String? id;
  final String? name;

  const FarmVarietyRefModel({this.id, this.name});

  factory FarmVarietyRefModel.fromJson(Map<String, dynamic> json) {
    return FarmVarietyRefModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class FinancialYearModel extends Equatable {
  final String? id;
  final String? label;

  const FinancialYearModel({this.id, this.label});

  factory FinancialYearModel.fromJson(Map<String, dynamic> json) {
    return FinancialYearModel(
      id: json['id'] as String?,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label};

  @override
  List<Object?> get props => [id, label];
}
