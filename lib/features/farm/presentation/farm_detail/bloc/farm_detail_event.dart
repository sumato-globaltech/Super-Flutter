import 'package:equatable/equatable.dart';

sealed class FarmDetailEvent extends Equatable {
  const FarmDetailEvent();

  @override
  List<Object?> get props => [];
}

class FarmDetailStarted extends FarmDetailEvent {
  final String farmId;

  const FarmDetailStarted(this.farmId);

  @override
  List<Object?> get props => [farmId];
}

class FarmDetailRefreshed extends FarmDetailEvent {
  const FarmDetailRefreshed();
}

class FarmArchiveToggled extends FarmDetailEvent {
  const FarmArchiveToggled();
}

class FarmDeleted extends FarmDetailEvent {
  const FarmDeleted();
}

class FarmCropAdded extends FarmDetailEvent {
  final Map<String, dynamic> data;

  const FarmCropAdded(this.data);

  @override
  List<Object?> get props => [data];
}

class FarmCropDeleted extends FarmDetailEvent {
  final String cropId;

  const FarmCropDeleted(this.cropId);

  @override
  List<Object?> get props => [cropId];
}

class FarmTransactionAdded extends FarmDetailEvent {
  final Map<String, dynamic> data;

  const FarmTransactionAdded(this.data);

  @override
  List<Object?> get props => [data];
}

class FarmPhotoUploaded extends FarmDetailEvent {
  final String filePath;

  const FarmPhotoUploaded(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class FarmPhotoDeleted extends FarmDetailEvent {
  final String photoId;

  const FarmPhotoDeleted(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

class FarmDetailTabChanged extends FarmDetailEvent {
  final int index;

  const FarmDetailTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}
