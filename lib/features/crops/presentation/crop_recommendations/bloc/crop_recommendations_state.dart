import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';

enum RecommendationsStatus { initial, loading, success, failure }

class CropRecommendationsState extends Equatable {
  final RecommendationsStatus optionsStatus;
  final String? optionsError;
  final List<DistrictOptionModel> districts;
  final List<CropModel> crops;
  final List<MonthModel> months;
  final RecommendationsStatus status;
  final String cropSlug;
  final String districtId;
  final int sowingMonth;
  final double areaHa;
  final CropRecommendationResultModel? result;
  final String? errorMessage;

  const CropRecommendationsState({
    this.optionsStatus = RecommendationsStatus.initial,
    this.optionsError,
    this.districts = const [],
    this.crops = const [],
    this.months = const [],
    this.status = RecommendationsStatus.initial,
    this.cropSlug = '',
    this.districtId = '',
    this.sowingMonth = 1,
    this.areaHa = 1.0,
    this.result,
    this.errorMessage,
  });

  CropRecommendationsState copyWith({
    RecommendationsStatus? optionsStatus,
    String? optionsError,
    List<DistrictOptionModel>? districts,
    List<CropModel>? crops,
    List<MonthModel>? months,
    RecommendationsStatus? status,
    String? cropSlug,
    String? districtId,
    int? sowingMonth,
    double? areaHa,
    CropRecommendationResultModel? result,
    String? errorMessage,
  }) {
    return CropRecommendationsState(
      optionsStatus: optionsStatus ?? this.optionsStatus,
      optionsError: optionsError,
      districts: districts ?? this.districts,
      crops: crops ?? this.crops,
      months: months ?? this.months,
      status: status ?? this.status,
      cropSlug: cropSlug ?? this.cropSlug,
      districtId: districtId ?? this.districtId,
      sowingMonth: sowingMonth ?? this.sowingMonth,
      areaHa: areaHa ?? this.areaHa,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        optionsStatus,
        optionsError,
        districts,
        crops,
        months,
        status,
        cropSlug,
        districtId,
        sowingMonth,
        areaHa,
        result,
        errorMessage,
      ];
}
