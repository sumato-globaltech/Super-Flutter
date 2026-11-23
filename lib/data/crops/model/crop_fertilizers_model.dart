import 'package:equatable/equatable.dart';
import 'crop_advisory_model.dart';
import 'crop_model.dart';

class CropFertilizersModel extends Equatable {
  final CropModel? crop;
  final dynamic nutrition;
  final List<CropFertilizerGroupModel> fertilizers;

  const CropFertilizersModel({
    this.crop,
    this.nutrition,
    this.fertilizers = const [],
  });

  factory CropFertilizersModel.fromJson(Map<String, dynamic> json) {
    final rawFertilizers = json['fertilizers'];
    final parsedFertilizers = rawFertilizers is List
        ? rawFertilizers
            .whereType<Map>()
            .map((e) =>
                CropFertilizerGroupModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CropFertilizerGroupModel>[];

    return CropFertilizersModel(
      crop: json['crop'] is Map
          ? CropModel.fromJson(Map<String, dynamic>.from(json['crop'] as Map))
          : null,
      nutrition: json['nutrition'],
      fertilizers: parsedFertilizers,
    );
  }

  @override
  List<Object?> get props => [crop, nutrition, fertilizers];
}
