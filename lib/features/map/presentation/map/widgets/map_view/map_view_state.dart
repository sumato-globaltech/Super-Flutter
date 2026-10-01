import 'package:equatable/equatable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_bounding_box.dart';
import 'package:super_flutter/features/map/presentation/map/widgets/map_view/map_point.dart';

/// Immutable camera snapshot shared between [MapView] and [MapScreenCubit].
/// The view publishes it on camera-idle; the Cubit publishes it to buttons.
class MapViewState extends Equatable {
  final MapPoint center;
  final MapBoundingBox? boundingBox;
  final MapPoint? focusPoint;
  final double zoom;
  final double bearing;
  final double tilt;
  final int resetVersion;

  const MapViewState({
    // this.center = const MapPoint(latitude: 26.115103, longitude: 91.703239),
    this.center = const MapPoint(latitude: 25.55711865, longitude: 93.7520957),
    this.boundingBox,
    this.focusPoint,
    this.zoom = 8.0,
    this.bearing = 0.0,
    this.tilt = 0.0,
    this.resetVersion = 1,
  });

  @override
  List<Object?> get props => [center, boundingBox, focusPoint, zoom, bearing, tilt, resetVersion];

  /// Returns a copy with the given fields replaced. Callers must spread
  /// previous maps/objects explicitly — no deep merging is performed.
  MapViewState copyWith({
    MapPoint? center,
    MapBoundingBox? boundingBox,
    MapPoint? focusPoint,
    double? zoom,
    double? bearing,
    double? tilt,
    int? resetVersion,
  }) {
    return MapViewState(
      center: center ?? this.center,
      boundingBox: boundingBox ?? this.boundingBox,
      focusPoint: focusPoint ?? this.focusPoint,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
      tilt: tilt ?? this.tilt,
      resetVersion: resetVersion ?? this.resetVersion,
    );
  }

  /// Compact rendering for the on-screen debug overlay.
  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("{");
    buffer.write("center: ${center.toString()},");
    buffer.write("zoom: $zoom,");
    buffer.write("tilt: $tilt,");
    buffer.write("bearing: $bearing,");
    buffer.write("}");
    return buffer.toString();
  }
}

/// Converts a [MapPoint] to the plugin's [LatLng] for camera calls.
extension MapPointX on MapPoint {
  LatLng get latLng => LatLng(latitude, longitude);
}

/// Builds a plugin [CameraPosition] from a snapshot, for animate/move calls.
extension MapViewStateX on MapViewState {
  CameraPosition get cameraPosition =>
      CameraPosition(target: center.latLng, zoom: zoom, bearing: bearing, tilt: tilt);
}
