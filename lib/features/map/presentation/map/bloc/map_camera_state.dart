import 'package:equatable/equatable.dart';

class MapCameraState extends Equatable {
  const MapCameraState({this.isReady = false, this.isMoving = false});

  final bool isReady;
  final bool isMoving;

  bool get canInteract => isReady && !isMoving;

  MapCameraState copyWith({bool? isReady, bool? isMoving}) {
    return MapCameraState(
      isReady: isReady ?? this.isReady,
      isMoving: isMoving ?? this.isMoving,
    );
  }

  @override
  List<Object?> get props => [isReady, isMoving];
}
