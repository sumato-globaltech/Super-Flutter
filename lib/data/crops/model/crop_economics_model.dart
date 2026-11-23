import 'package:equatable/equatable.dart';
import 'crop_model.dart';

class CropEconomicsModel extends Equatable {
  final CropModel? crop;
  final DistrictModel? district;
  final Map<String, dynamic>? economics;

  const CropEconomicsModel({
    this.crop,
    this.district,
    this.economics,
  });

  factory CropEconomicsModel.fromJson(Map<String, dynamic> json) {
    return CropEconomicsModel(
      crop: json['crop'] is Map
          ? CropModel.fromJson(Map<String, dynamic>.from(json['crop'] as Map))
          : null,
      district: json['district'] is Map
          ? DistrictModel.fromJson(
              Map<String, dynamic>.from(json['district'] as Map),
            )
          : null,
      economics: json['economics'] is Map
          ? Map<String, dynamic>.from(json['economics'] as Map)
          : null,
    );
  }

  @override
  List<Object?> get props => [crop, district, economics];
}
