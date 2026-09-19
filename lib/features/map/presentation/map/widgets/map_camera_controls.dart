import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_bloc.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_event.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_camera_state.dart';

/// Floating camera controls overlay: zoom, tilt (pitch), bearing rotation,
/// and North-up reset. Disabled until the map controller is ready.
class MapCameraControls extends StatelessWidget {
  const MapCameraControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCameraBloc, MapCameraState>(
      builder: (context, state) {
        final bloc = context.read<MapCameraBloc>();
        final enabled = state.canInteract;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ControlButton(
              tooltip: 'Zoom in',
              icon: Icons.add,
              enabled: enabled,
              onPressed: () => bloc.add(const MapZoomInRequested()),
            ),
            const SizedBox(height: 8),
            _ControlButton(
              tooltip: 'Zoom out',
              icon: Icons.remove,
              enabled: enabled,
              onPressed: () => bloc.add(const MapZoomOutRequested()),
            ),
            const SizedBox(height: 16),
            _ControlButton(
              tooltip: 'Tilt up',
              icon: Icons.arrow_upward_outlined,
              enabled: enabled,
              onPressed: () => bloc.add(const MapTiltUpRequested()),
            ),
            const SizedBox(height: 8),
            _ControlButton(
              tooltip: 'Tilt down',
              icon: Icons.arrow_downward_outlined,
              enabled: enabled,
              onPressed: () => bloc.add(const MapTiltDownRequested()),
            ),
            const SizedBox(height: 16),
            _ControlButton(
              tooltip: 'Rotate left',
              icon: Icons.rotate_left_outlined,
              enabled: enabled,
              onPressed: () => bloc.add(const MapRotateLeftRequested()),
            ),
            const SizedBox(height: 8),
            _ControlButton(
              tooltip: 'Rotate right',
              icon: Icons.rotate_right_outlined,
              enabled: enabled,
              onPressed: () => bloc.add(const MapRotateRightRequested()),
            ),
            const SizedBox(height: 16),
            _ControlButton(
              tooltip: state.globeEnabled
                  ? 'Switch to flat map'
                  : 'Switch to globe',
              icon: Icons.public_outlined,
              enabled: enabled,
              selected: state.globeEnabled,
              onPressed: () => bloc.add(const MapProjectionToggled()),
            ),
            const SizedBox(height: 16),
            _ControlButton(
              tooltip: 'Reset North-up',
              icon: Icons.explore_outlined,
              enabled: enabled,
              onPressed: () => bloc.add(const MapNorthUpRequested()),
            ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: FloatingActionButton.small(
        heroTag: tooltip,
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        backgroundColor: selected ? scheme.primary : null,
        foregroundColor: selected ? scheme.onPrimary : null,
        child: Icon(icon),
      ),
    );
  }
}
