import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';

enum RecommendationsStatus { initial, loading, success, failure }

class CropRecommendationsState extends Equatable {
  final RecommendationsStatus status;
  final String districtId;
  final int sowingMonth;
  final double areaHa;
  final CropRecommendationResultModel? result;
  final String? errorMessage;

  const CropRecommendationsState({
    this.status = RecommendationsStatus.initial,
    this.districtId = '',
    this.sowingMonth = 1,
    this.areaHa = 1.0,
    this.result,
    this.errorMessage,
  });

  CropRecommendationsState copyWith({
    RecommendationsStatus? status,
    String? districtId,
    int? sowingMonth,
    double? areaHa,
    CropRecommendationResultModel? result,
    String? errorMessage,
  }) {
    return CropRecommendationsState(
      status: status ?? this.status,
      districtId: districtId ?? this.districtId,
      sowingMonth: sowingMonth ?? this.sowingMonth,
      areaHa: areaHa ?? this.areaHa,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        districtId,
        sowingMonth,
        areaHa,
        result,
        errorMessage,
      ];
}
