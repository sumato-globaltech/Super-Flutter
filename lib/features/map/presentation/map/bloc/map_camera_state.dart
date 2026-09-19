import 'package:equatable/equatable.dart';

class MapCameraState extends Equatable {
  const MapCameraState({
    this.isReady = false,
    this.isMoving = false,
    this.globeEnabled = false,
  });

  final bool isReady;
  final bool isMoving;

  /// True once globe projection + terrain + sky were applied (web only).
  final bool globeEnabled;

  bool get canInteract => isReady && !isMoving;

  MapCameraState copyWith({
    bool? isReady,
    bool? isMoving,
    bool? globeEnabled,
  }) {
    return MapCameraState(
      isReady: isReady ?? this.isReady,
      isMoving: isMoving ?? this.isMoving,
      globeEnabled: globeEnabled ?? this.globeEnabled,
    );
  }

  @override
  List<Object?> get props => [isReady, isMoving, globeEnabled];
}
