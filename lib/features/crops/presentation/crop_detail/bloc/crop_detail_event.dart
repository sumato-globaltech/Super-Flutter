import 'package:equatable/equatable.dart';

sealed class CropDetailEvent extends Equatable {
  const CropDetailEvent();

  @override
  List<Object?> get props => [];
}

class CropDetailStarted extends CropDetailEvent {
  final String slug;
  final String? districtId;

  const CropDetailStarted(this.slug, {this.districtId});

  @override
  List<Object?> get props => [slug, districtId];
}

class CropDetailTabChanged extends CropDetailEvent {
  final int index;

  const CropDetailTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class CropDetailRefreshed extends CropDetailEvent {
  const CropDetailRefreshed();
}

class CropDetailPricesMoreRequested extends CropDetailEvent {
  const CropDetailPricesMoreRequested();
}
