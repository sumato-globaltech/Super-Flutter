import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/production/model/production_insights_model.dart';

enum ProductionStatus { initial, loading, success, failure }

/// Month number and crop slug; null shows all of them.
typedef ProductionFilter = ({int? month, String? crop});

class ProductionState extends Equatable {
  const ProductionState({
    this.status = ProductionStatus.initial,
    this.productionInsights,
    this.errorMessage,
    this.filter = (month: null, crop: null),
    this.crops = const [],
  });

  final ProductionStatus status;
  final ProductionInsightsModel? productionInsights;
  final String? errorMessage;
  final ProductionFilter filter;
  final List<CropModel> crops;

  ProductionState copyWith({
    ProductionStatus? status,
    ProductionInsightsModel? productionInsights,
    String? errorMessage,
    ProductionFilter? filter,
    List<CropModel>? crops,
  }) {
    return ProductionState(
      status: status ?? this.status,
      productionInsights: productionInsights ?? this.productionInsights,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
      crops: crops ?? this.crops,
    );
  }

  @override
  List<Object?> get props => [
    status,
    productionInsights,
    errorMessage,
    filter,
    crops,
  ];
}
