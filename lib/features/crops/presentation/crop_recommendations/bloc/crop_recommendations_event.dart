import 'package:equatable/equatable.dart';

sealed class CropRecommendationsEvent extends Equatable {
  const CropRecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class RecommendationsStarted extends CropRecommendationsEvent {
  const RecommendationsStarted();
}

class RecommendationsCropChanged extends CropRecommendationsEvent {
  /// Empty for all crops.
  final String cropSlug;

  const RecommendationsCropChanged(this.cropSlug);

  @override
  List<Object?> get props => [cropSlug];
}

class RecommendationsDistrictChanged extends CropRecommendationsEvent {
  final String districtId;

  const RecommendationsDistrictChanged(this.districtId);

  @override
  List<Object?> get props => [districtId];
}

class RecommendationsMonthChanged extends CropRecommendationsEvent {
  final int month;

  const RecommendationsMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

class RecommendationsAreaChanged extends CropRecommendationsEvent {
  final double area;

  const RecommendationsAreaChanged(this.area);

  @override
  List<Object?> get props => [area];
}

class RecommendationsSubmitted extends CropRecommendationsEvent {
  const RecommendationsSubmitted();
}
