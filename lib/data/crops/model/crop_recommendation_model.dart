import 'package:equatable/equatable.dart';

import 'crop_advisory_model.dart';
import 'crop_model.dart';

class CropRecommendationResultModel extends Equatable {
  final CropRecommendationInputModel? input;
  final List<CropRecommendationItemModel> results;
  final List<dynamic> excluded;

  const CropRecommendationResultModel({
    this.input,
    this.results = const [],
    this.excluded = const [],
  });

  factory CropRecommendationResultModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];
    final parsedResults = rawResults is List
        ? rawResults
              .whereType<Map>()
              .map(
                (e) => CropRecommendationItemModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <CropRecommendationItemModel>[];

    return CropRecommendationResultModel(
      input: json['input'] is Map
          ? CropRecommendationInputModel.fromJson(
              Map<String, dynamic>.from(json['input'] as Map),
            )
          : null,
      results: parsedResults,
      excluded: json['excluded'] is List ? json['excluded'] as List : const [],
    );
  }

  @override
  List<Object?> get props => [input, results, excluded];
}

class CropRecommendationInputModel extends Equatable {
  final DistrictModel? district;
  final MonthModel? sowingMonth;
  final double? areaHa;
  final String? financialYear;

  const CropRecommendationInputModel({
    this.district,
    this.sowingMonth,
    this.areaHa,
    this.financialYear,
  });

  factory CropRecommendationInputModel.fromJson(Map<String, dynamic> json) {
    return CropRecommendationInputModel(
      district: json['district'] is Map
          ? DistrictModel.fromJson(
              Map<String, dynamic>.from(json['district'] as Map),
            )
          : null,
      sowingMonth: json['sowing_month'] is Map
          ? MonthModel.fromJson(
              Map<String, dynamic>.from(json['sowing_month'] as Map),
            )
          : null,
      areaHa: json['area_ha'] is num
          ? (json['area_ha'] as num).toDouble()
          : double.tryParse('${json['area_ha']}'),
      financialYear: json['financial_year'] as String?,
    );
  }

  @override
  List<Object?> get props => [district, sowingMonth, areaHa, financialYear];
}

class CropRecommendationItemModel extends Equatable {
  final int? rank;
  final CropModel? crop;
  final String? suitability;
  final String? suitabilityLabel;
  final num? suitabilityScore;
  final String? sowingWindow;
  final Map<String, dynamic>? expected;
  final List<String> notes;

  const CropRecommendationItemModel({
    this.rank,
    this.crop,
    this.suitability,
    this.suitabilityLabel,
    this.suitabilityScore,
    this.sowingWindow,
    this.expected,
    this.notes = const [],
  });

  factory CropRecommendationItemModel.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['notes'];
    final parsedNotes = rawNotes is List
        ? rawNotes.map((e) => e.toString()).toList()
        : <String>[];

    return CropRecommendationItemModel(
      rank: json['rank'] is int
          ? json['rank'] as int
          : int.tryParse('${json['rank']}'),
      crop: json['crop'] is Map
          ? CropModel.fromJson(Map<String, dynamic>.from(json['crop'] as Map))
          : null,
      suitability: json['suitability'] as String?,
      suitabilityLabel: json['suitability_label'] as String?,
      suitabilityScore: json['suitability_score'] is num
          ? json['suitability_score'] as num
          : num.tryParse('${json['suitability_score']}'),
      sowingWindow: json['sowing_window']?.toString(),
      expected: json['expected'] is Map
          ? Map<String, dynamic>.from(json['expected'] as Map)
          : null,
      notes: parsedNotes,
    );
  }

  @override
  List<Object?> get props => [
    rank,
    crop,
    suitability,
    suitabilityLabel,
    suitabilityScore,
    sowingWindow,
    expected,
    notes,
  ];
}
