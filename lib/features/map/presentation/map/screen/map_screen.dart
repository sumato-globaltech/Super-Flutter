import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/ui/widgets/app_button.dart';
import 'package:super_flutter/core/ui/widgets/app_loader.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_cubit.dart';
import 'package:super_flutter/features/map/presentation/map/bloc/map_screen_state.dart';

import 'package:super_flutter/components/map_view/view/map_view.dart';

/// Map feature entry screen: native [MapView] plus camera buttons, layer
/// panel, loading overlay, and retry banner — all driven by [MapScreenCubit].
class MapScreenNew extends StatefulWidget {
  const MapScreenNew({super.key});

  @override
  State<MapScreenNew> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenNew> {
  late MapScreenCubit cubit;
  MapLibreMapController? mapController;
  bool _layersOpen = false;

  @override
  void initState() {
    cubit = getIt.get<MapScreenCubit>();

    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MapScreenCubit, MapScreenState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              body: Stack(
                children: [
                  MapView(
                    onMapInitialized: (controller) {},
                    onMapReady: (controller) async {
                      mapController = controller;
                      await cubit.ensureBaseLayers(controller);
                      await cubit.ensureOverlayGroup(controller);
                    },
                    mapViewState: state.mapViewState,
                    mapCommand: cubit.mapCommand,
                    onMapViewState: (mapViewState) {
                      cubit.mapViewStateChanged(mapViewState);
                    },
                  ),
                  if (state.layersLoading)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: Center(child: AppLoader(message: 'Loading map layers')),
                      ),
                    ),
                  if (state.layersPartialFailure)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 32,
                      child: _LayersRetryBanner(
                        failed: state.layersFailed,
                        onRetry: () {
                          final controller = mapController;
                          if (controller != null) {
                            cubit.refreshLayers(controller);
                          }
                        },
                      ),
                    ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _LayersPanel(
                      open: _layersOpen,
                      onToggleOpen: () => setState(() => _layersOpen = !_layersOpen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tilt - ${state.mapViewState.tilt}"),
                        Text("Zoom - ${state.mapViewState.zoom}"),
                        Text("Bearing - ${state.mapViewState.bearing}"),
                        Text("Center - ${state.mapViewState.center.toString()}"),
                        SizedBox(height: 24),
                        _ControlButton(
                          tooltip: 'Zoom in',
                          icon: Icons.add,
                          enabled: true,
                          onPressed: () {
                            cubit.makeZoomIn();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Zoom out',
                          icon: Icons.remove,
                          enabled: true,
                          onPressed: () {
                            cubit.makeZoomOut();
                          },
                        ),
                        const SizedBox(height: 16),
                        _ControlButton(
                          tooltip: 'Tilt up',
                          icon: Icons.arrow_upward_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.tiltUp();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Tilt down',
                          icon: Icons.arrow_downward_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.tiltDown();
                          },
                        ),
                        const SizedBox(height: 16),
                        _ControlButton(
                          tooltip: 'Rotate left',
                          icon: Icons.rotate_left_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.rotateLeft();
                          },
                        ),
                        const SizedBox(height: 8),
                        _ControlButton(
                          tooltip: 'Rotate right',
                          icon: Icons.rotate_right_outlined,
                          enabled: true,
                          onPressed: () {
                            cubit.rotateRight();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Expandable layers entry point docked at the top-right. The toggle button
/// is always visible; the [_LayersCard] below it only mounts while open.
class _LayersPanel extends StatelessWidget {
  const _LayersPanel({required this.open, required this.onToggleOpen});  final bool open;
  final VoidCallback onToggleOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'layers-panel-toggle',
          tooltip: open ? 'Hide layers' : 'Show layers',
          onPressed: onToggleOpen,
          child: const Icon(Icons.layers_outlined),
        ),
        if (open) ...[const SizedBox(height: 8), const _LayersCard()],
      ],
    );
  }
}

/// Lists one [_LayerRow] per catalog definition from the Cubit. Reads the
/// native controller from the ancestor screen state, so rows disable
/// themselves before the style is ready instead of crashing on null.
class _LayersCard extends StatelessWidget {
  const _LayersCard();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapScreenCubit>();
    final state = context.watch<MapScreenCubit>().state;
    final screenState = context.findAncestorStateOfType<_MapScreenState>();
    final controller = screenState?.mapController;
    final defs = cubit.layerDefinitions;
    return Card(
      child: Container(
        width: 248,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: defs.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Layers load with the map style.'),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final def in defs)
                    _LayerRow(
                      key: ValueKey(def.id),
                      layerId: def.id,
                      group: def.group,
                      visible: state.layerVisibility[def.id] ?? def.visible,
                      opacity: state.layerOpacity[def.id] ?? 1.0,
                      exaggeration:
                          state.layerExaggeration[def.id] ??
                          def.hillshadeExaggeration ??
                          1.0,
                      showOpacity: def.supportsOpacity,
                      showExaggeration: def.supportsExaggeration,
                      enabled: controller != null && !state.layersLoading,
                      onToggle: controller == null
                          ? null
                          : () => cubit.toggleLayer(controller, def),
                      onOpacityCommitted: controller == null
                          ? null
                          : (value) => cubit.setLayerOpacity(controller, def, value),
                      onExaggerationCommitted: controller == null
                          ? null
                          : (value) => cubit.setHillshadeExaggeration(
                              controller,
                              def,
                              value,
                            ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// One layer's controls: visibility switch plus an opacity and/or
/// exaggeration slider, shown only for kinds that support them
/// ([LayerDefinition.supportsOpacity]/[supportsExaggeration]).
class _LayerRow extends StatefulWidget {
  const _LayerRow({
    super.key,
    required this.layerId,
    required this.group,
    required this.visible,
    required this.opacity,
    required this.exaggeration,
    required this.showOpacity,
    required this.showExaggeration,
    required this.enabled,
    required this.onToggle,
    required this.onOpacityCommitted,
    required this.onExaggerationCommitted,
  });

  final String layerId;
  final String group;
  final bool visible;
  final double opacity;
  final double exaggeration;
  final bool showOpacity;
  final bool showExaggeration;
  final bool enabled;
  final VoidCallback? onToggle;
  final ValueChanged<double>? onOpacityCommitted;
  final ValueChanged<double>? onExaggerationCommitted;

  @override
  State<_LayerRow> createState() => _LayerRowState();
}

class _LayerRowState extends State<_LayerRow> {
  double? _dragValue;
  double? _dragExaggeration;

  @override
  void didUpdateWidget(covariant _LayerRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opacity != widget.opacity) _dragValue = null;
    if (oldWidget.exaggeration != widget.exaggeration) {
      _dragExaggeration = null;
    }
  }

  /// True only when sliders may commit: panel enabled, controller ready,
  /// and at least one slider has a commit callback. Drag previews still work
  /// while disabled via local [_dragValue] state.
  bool get _interactive =>
      widget.enabled &&
      (widget.onOpacityCommitted != null ||
          widget.onExaggerationCommitted != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Layer ${widget.layerId}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.layerId,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(widget.group, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Switch(
                  value: widget.visible,
                  onChanged: widget.enabled && widget.onToggle != null
                      ? (_) => widget.onToggle!()
                      : null,
                ),
              ],
            ),
            if (widget.showOpacity)
              _LabeledSlider(
                label: 'Opacity',
                value: (_dragValue ?? widget.opacity).clamp(0.0, 1.0),
                min: 0,
                max: 1,
                enabled: _interactive,
                onChanged: (v) => setState(() => _dragValue = v),
                onChangeEnd: (v) {
                  setState(() => _dragValue = null);
                  widget.onOpacityCommitted?.call(v);
                },
              ),
            if (widget.showExaggeration)
              _LabeledSlider(
                label: 'Exaggeration',
                value: (_dragExaggeration ?? widget.exaggeration).clamp(0.0, 5.0),
                min: 0,
                max: 5,
                enabled: _interactive,
                onChanged: (v) => setState(() => _dragExaggeration = v),
                onChangeEnd: (v) {
                  setState(() => _dragExaggeration = null);
                  widget.onExaggerationCommitted?.call(v);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Label + slider pair used for opacity (0–1) and exaggeration (0–5).
/// Drags preview locally in [_LayerRowState]; only `onChangeEnd` commits to
/// the Cubit, since every commit re-adds the native layer.
class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: enabled ? onChanged : null,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

/// Bottom banner shown when layer setup finished with failures. Retry
/// re-runs the base pipeline via [MapScreenCubit.refreshLayers].
class _LayersRetryBanner extends StatelessWidget {
  const _LayersRetryBanner({required this.failed, required this.onRetry});

  final List<String> failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Some map layers failed to load (${failed.length}).',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            AppButton.outlined(label: 'Retry', onPressed: onRetry, isExpanded: false),
          ],
        ),
      ),
    );
  }
}

/// Small round camera button (zoom/tilt/rotate) with tooltip and
/// accessibility label. `heroTag: tooltip` keeps tags unique per button.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: FloatingActionButton.small(
        heroTag: tooltip,
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        child: Icon(icon),
      ),
    );
  }
}
