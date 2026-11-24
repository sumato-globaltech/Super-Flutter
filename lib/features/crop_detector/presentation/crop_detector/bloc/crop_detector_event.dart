import 'package:equatable/equatable.dart';

sealed class CropDetectorEvent extends Equatable {
  const CropDetectorEvent();

  @override
  List<Object?> get props => [];
}

class CropPhotoChosen extends CropDetectorEvent {
  const CropPhotoChosen({required this.path, required this.fromGallery});

  final String path;
  final bool fromGallery;

  @override
  List<Object?> get props => [path, fromGallery];
}
