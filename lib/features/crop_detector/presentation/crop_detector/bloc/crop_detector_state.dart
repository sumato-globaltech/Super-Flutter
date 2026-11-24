import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crop_detector/model/crop_analysis_model.dart';

enum CropDetectorStatus { initial, analysing, success, failure }

class CropDetectorState extends Equatable {
  const CropDetectorState({
    this.status = CropDetectorStatus.initial,
    this.photo,
    this.fromGallery = false,
    this.analysis,
    this.errorMessage,
  });

  final CropDetectorStatus status;
  final String? photo;
  final bool fromGallery;
  final CropAnalysisModel? analysis;
  final String? errorMessage;

  bool get isAnalysing => status == CropDetectorStatus.analysing;

  @override
  List<Object?> get props => [
    status,
    photo,
    fromGallery,
    analysis,
    errorMessage,
  ];
}
