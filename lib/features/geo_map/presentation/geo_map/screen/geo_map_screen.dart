import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:map_forge/map_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/constants/asset_constants.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/data/geo_map/model/district_info_model.dart';
import 'package:super_flutter/data/geo_map/model/office_location_model.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_station_model.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_bloc.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_event.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_area_card.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_crop_tray.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_details_card.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_layer_tray.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_marker_card.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/geo_map_nav_bar.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/widgets/map_chrome.dart';

class GeoMapScreen extends StatefulWidget {
  const GeoMapScreen({super.key});

  @override
  State<GeoMapScreen> createState() => _GeoMapScreenState();
}

class _GeoMapScreenState extends State<GeoMapScreen> {
  late final MapForgeController _map;
  String? _style;
  Object? _styleError;
  bool _runtimeReady = false;
  String? _selectedDistrictKey;
  Set<GeoMapCrop> _appliedCrops = const {};
  Set<GeoMapLayer>? _lastLayers;
  Set<GeoMapCrop>? _lastCrops;
  List<OfficeLocationModel>? _lastOffices;
  MarkerState? _lastMarker;
  AreaDrawing? _lastArea;
  LayerDefinition? _districtFillDefinition;

  @override
  void initState() {
    super.initState();
    _map = MapForgeController(
      catalog: AssetLayerCatalog(catalogPath: AssetConstants.geoMapCatalog),
      screen: 'geo_map',
    );
    unawaited(_loadStyle());
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  Future<void> _loadStyle() async {
    try {
      final style = await rootBundle.loadString(AssetConstants.geoMapStyle);
      if (!mounted) return;
      setState(() => _style = style);
    } catch (error) {
      if (!mounted) return;
      setState(() => _styleError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GeoMapBloc>()..add(const GeoMapStarted()),
      child: BlocConsumer<GeoMapBloc, GeoMapState>(
        listenWhen: (previous, current) =>
            previous.message != current.message ||
            previous.visibleLayers != current.visibleLayers ||
            previous.visibleCrops != current.visibleCrops ||
            previous.offices != current.offices ||
            previous.marker != current.marker ||
            previous.area != current.area ||
            previous.selection != current.selection,
        listener: _onStateChanged,
        builder: (context, state) {
          if (_styleError != null) {
            return _StyleError(
              onRetry: () {
                setState(() => _styleError = null);
                unawaited(_loadStyle());
              },
            );
          }
          if (_style == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: _buildMap(context, state),
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, GeoMapState state) {
    final top = MediaQuery.paddingOf(context).top + 118;
    return Stack(
      children: [
        Positioned.fill(
          child: MapForgeView(
            controller: _map,
            styleString: _style!,
            myLocationEnabled: false,
            onMapReady: (_) => unawaited(_onMapReady()),
            onTap: (result) => _onTap(context, result),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GeoMapNavBar(
            query: state.searchQuery,
            results: state.searchResults,
            villagesLoaded: state.villagesLoaded,
            zoom: _map.state.zoom,
            activeTool: state.activeTool,
            layersExpanded: state.layersExpanded,
            cropsExpanded: state.cropsExpanded,
            onQueryChanged: (query) =>
                context.read<GeoMapBloc>().add(GeoMapSearchQueryChanged(query)),
            onVillageSelected: (village) =>
                _onVillageSearched(context, village),
            onToggleLayers: () =>
                context.read<GeoMapBloc>().add(const GeoMapLayersTrayToggled()),
            onToggleCrops: () =>
                context.read<GeoMapBloc>().add(const GeoMapCropsTrayToggled()),
            onToggleTool: (tool) =>
                context.read<GeoMapBloc>().add(GeoMapToolToggled(tool)),
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
            onResetCamera: _map.resetCamera,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(DashboardRouteNames.dashboard);
              }
            },
          ),
        ),
        if (state.selection != null)
          Positioned(
            top: top,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.topLeft,
              child: GeoMapDetailsCard(
                selection: state.selection!,
                onClose: () => context.read<GeoMapBloc>().add(
                  const GeoMapSelectionCleared(),
                ),
              ),
            ),
          ),
        if (state.marker != null &&
            state.activeTool != GeoMapTool.areaMeasurement)
          Positioned(
            top: top,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.topLeft,
              child: GeoMapMarkerCard(
                marker: state.marker!,
                onTabSelected: (tab) => context.read<GeoMapBloc>().add(
                  GeoMapMarkerTabSelected(tab),
                ),
                onRetry: () =>
                    context.read<GeoMapBloc>().add(const GeoMapMarkerRetried()),
                onClose: () =>
                    context.read<GeoMapBloc>().add(const GeoMapMarkerCleared()),
              ),
            ),
          ),
        if (state.activeTool == GeoMapTool.areaMeasurement)
          Positioned(
            top: top,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.topLeft,
              child: GeoMapAreaCard(
                area: state.area,
                onUndo: () => context.read<GeoMapBloc>().add(
                  const GeoMapAreaPointUndone(),
                ),
                onClear: () =>
                    context.read<GeoMapBloc>().add(const GeoMapAreaCleared()),
                onClose: () =>
                    context.read<GeoMapBloc>().add(const GeoMapAreaClosed()),
              ),
            ),
          ),
        if (state.activeTool == GeoMapTool.suitability &&
            state.marker == null &&
            state.searchQuery.isEmpty)
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: MapChrome.background.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MapChrome.border),
                ),
                child: const Text(
                  'Tap the map to place a point',
                  style: TextStyle(color: MapChrome.content, fontSize: 12),
                ),
              ),
            ),
          ),
        if (state.layersExpanded)
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GeoMapLayerTray(
                visibleLayers: state.visibleLayers,
                onToggle: (layer) =>
                    context.read<GeoMapBloc>().add(GeoMapLayerToggled(layer)),
              ),
            ),
          ),
        if (state.cropsExpanded)
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GeoMapCropTray(
                visibleCrops: state.visibleCrops,
                onToggle: (crop) =>
                    context.read<GeoMapBloc>().add(GeoMapCropToggled(crop)),
              ),
            ),
          ),
      ],
    );
  }

  void _onStateChanged(BuildContext context, GeoMapState state) {
    final message = state.message;
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      context.read<GeoMapBloc>().add(const GeoMapMessageShown());
    }
    final layersChanged =
        _lastLayers != state.visibleLayers || _lastCrops != state.visibleCrops;
    final runtimeChanged =
        _lastOffices != state.offices ||
        _lastMarker != state.marker ||
        _lastArea != state.area;
    _lastLayers = state.visibleLayers;
    _lastCrops = state.visibleCrops;
    _lastOffices = state.offices;
    _lastMarker = state.marker;
    _lastArea = state.area;
    if (_runtimeReady) {
      if (layersChanged) unawaited(_syncLayers(state));
      if (runtimeChanged) unawaited(_syncRuntimeData(state));
    }
    _syncDistrictSelection(state);
  }

  Future<void> _onMapReady() async {
    try {
      await _map.ensureGroup('overlays');
    } catch (_) {
      // A failed group is isolated by map_forge; the map stays usable.
    }
    if (!mounted) return;
    for (final layer in _map.layers) {
      if (layer.id == 'districts_fill') {
        _districtFillDefinition = layer;
        break;
      }
    }
    await _ensureRuntimeLayers();
    if (!mounted) return;
    _runtimeReady = true;
    final state = context.read<GeoMapBloc>().state;
    await _syncLayers(state);
    await _syncRuntimeData(state);
    _syncDistrictSelection(state);
  }

  Future<void> _ensureRuntimeLayers() async {
    await _map.ensureRuntimeLayer(
      LayerDefinition(
        id: 'geo_offices',
        sourceId: 'geo_offices',
        group: 'runtime',
        feature: 'geo_map',
        kind: LayerKind.symbol,
        source: const GeoJsonSource(data: _emptyCollection),
        visible: false,
        label: 'Offices',
        tappable: true,
        iconImage: 'geo_office',
        iconAsset: AssetConstants.geoMapOfficeIcon,
        iconSize: 0.12,
        iconOffset: const [0, -20],
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
      visible: false,
    );
    await _map.ensureRuntimeLayer(
      LayerDefinition(
        id: 'geo_marker',
        sourceId: 'geo_marker',
        group: 'runtime',
        feature: 'geo_map',
        kind: LayerKind.symbol,
        source: const GeoJsonSource(data: _emptyCollection),
        visible: false,
        tappable: false,
        belowLayerId: 'districts_fill',
        iconImage: 'geo_marker_pin',
        iconAsset: AssetConstants.geoMapMarkerIcon,
        iconSize: 0.64,
        iconOffset: const [0, -30],
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
      visible: false,
    );
    await _map.ensureRuntimeLayer(
      LayerDefinition(
        id: 'geo_area_line',
        sourceId: 'geo_area_line',
        group: 'runtime',
        feature: 'geo_map',
        kind: LayerKind.line,
        source: const GeoJsonSource(data: _emptyCollection),
        visible: false,
        tappable: false,
        belowLayerId: 'districts_fill',
        lineColor: '#ffffff',
        lineWidth: 2,
      ),
      visible: false,
    );
    await _map.ensureRuntimeLayer(
      LayerDefinition(
        id: 'geo_area_fill',
        sourceId: 'geo_area_fill',
        group: 'runtime',
        feature: 'geo_map',
        kind: LayerKind.fill,
        source: const GeoJsonSource(data: _emptyCollection),
        visible: false,
        tappable: false,
        belowLayerId: 'districts_fill',
        fillColor: 'rgba(128,0,128,0.28)',
        fillOpacity: 1,
      ),
      visible: false,
    );
    await _map.ensureRuntimeLayer(
      LayerDefinition(
        id: 'geo_area_points',
        sourceId: 'geo_area_points',
        group: 'runtime',
        feature: 'geo_map',
        kind: LayerKind.circle,
        source: const GeoJsonSource(data: _emptyCollection),
        visible: false,
        tappable: false,
        belowLayerId: 'districts_fill',
        circleRadius: 5,
        circleColor: '#ffffff',
        circleStrokeColor: '#800080',
        circleStrokeWidth: 2,
      ),
      visible: false,
    );
  }

  Future<void> _syncLayers(GeoMapState state) async {
    for (final layer in GeoMapLayer.values) {
      final visible = state.isLayerVisible(layer);
      if (layer == GeoMapLayer.offices) {
        await _map.setRuntimeLayerVisible('geo_offices', visible);
      } else {
        await _map.setLayerVisible(layer.layerId, visible);
        if (layer == GeoMapLayer.villages) {
          await _map.setLayerVisible('villages_labels', visible);
        }
      }
    }
    for (final crop in {..._appliedCrops, ...state.visibleCrops}) {
      await _map.setLayerVisible(
        crop.layerId,
        state.visibleCrops.contains(crop),
      );
    }
    _appliedCrops = state.visibleCrops;
  }

  Future<void> _syncRuntimeData(GeoMapState state) async {
    await _map.updateSourceData('geo_offices', _officesGeoJson(state.offices));
    final marker = state.marker;
    await _map.updateSourceData(
      'geo_marker',
      marker == null
          ? _emptyCollection
          : {
              'type': 'FeatureCollection',
              'features': [
                {
                  'type': 'Feature',
                  'geometry': {
                    'type': 'Point',
                    'coordinates': [
                      marker.position.longitude,
                      marker.position.latitude,
                    ],
                  },
                  'properties': const <String, dynamic>{},
                },
              ],
            },
    );
    await _map.setRuntimeLayerVisible('geo_marker', marker != null);

    final points = state.area.points;
    await _map.updateSourceData('geo_area_line', _areaLine(points));
    await _map.updateSourceData('geo_area_fill', _areaFill(points));
    await _map.updateSourceData('geo_area_points', _areaPoints(points));
    await _map.setRuntimeLayerVisible('geo_area_line', points.length >= 2);
    await _map.setRuntimeLayerVisible('geo_area_fill', points.length >= 3);
    await _map.setRuntimeLayerVisible('geo_area_points', points.isNotEmpty);
  }

  void _syncDistrictSelection(GeoMapState state) {
    final next = state.selection is DistrictSelection
        ? (state.selection! as DistrictSelection).info.name
        : null;
    if (next == _selectedDistrictKey) return;
    _selectedDistrictKey = next;
    final definition = _districtFillDefinition;
    if (definition == null) return;
    final fillColor = next == null
        ? 'rgba(0,0,0,0)'
        : <dynamic>[
            'case',
            <dynamic>[
              '==',
              <dynamic>['get', 'District_N'],
              next,
            ],
            'rgba(128,0,128,0.38)',
            'rgba(0,0,0,0)',
          ];
    unawaited(_map.updateLayer(definition.copyWith(fillColor: fillColor)));
  }

  void _onTap(BuildContext context, MapTapResult result) {
    final bloc = context.read<GeoMapBloc>();
    final state = bloc.state;
    if (state.activeTool != null) {
      bloc.add(
        GeoMapTapped(
          GeoPoint(
            latitude: result.point.latitude,
            longitude: result.point.longitude,
          ),
        ),
      );
      return;
    }

    final feature = result.feature;
    if (feature == null) {
      bloc.add(const GeoMapSelectionCleared());
      return;
    }

    final properties = feature.properties;
    final layerId = feature.layerId;

    if (layerId == 'districts_tap') {
      final name = '${properties['District_N'] ?? ''}';
      bloc.add(
        GeoMapDistrictSelected(
          DistrictInfoModel.fromProperties(name.toUpperCase(), properties),
        ),
      );
      return;
    }

    if (layerId == 'villages') {
      final village = _villageFromProperties(
        properties,
        result.point,
        state.villages,
      );
      bloc.add(GeoMapVillageSearched(village));
      return;
    }

    if (layerId == 'weather_stations') {
      bloc.add(
        GeoMapWeatherStationSelected(
          WeatherStationModel(
            district: '${properties['dist_name'] ?? ''}',
            latitude: result.point.latitude,
            longitude: result.point.longitude,
            attributes: {
              for (final entry in properties.entries)
                if (entry.value != null && '${entry.value}'.isNotEmpty)
                  entry.key: '${entry.value}',
            },
          ),
        ),
      );
      return;
    }

    if (layerId == 'geo_offices') {
      final id = '${properties['id'] ?? ''}';
      for (final office in state.offices) {
        if (office.id == id) {
          bloc.add(GeoMapOfficeSelected(office));
          return;
        }
      }
    }

    bloc.add(const GeoMapSelectionCleared());
  }

  VillageModel _villageFromProperties(
    Map<String, Object?> properties,
    MapPoint point,
    List<VillageModel> villages,
  ) {
    final name = '${properties['Vill_Name'] ?? ''}';
    final district = '${properties['dtname'] ?? ''}';
    for (final village in villages) {
      if (village.name == name &&
          (district.isEmpty || village.district == district)) {
        return village;
      }
    }
    return VillageModel(
      name: name,
      district: district,
      latitude: point.latitude,
      longitude: point.longitude,
      latitudeDms: '${properties['Latitude'] ?? ''}',
      longitudeDms: '${properties['Longitude'] ?? ''}',
    );
  }

  void _onVillageSearched(BuildContext context, VillageModel village) {
    context.read<GeoMapBloc>().add(GeoMapVillageSearched(village));
    _map.animateTo(
      target: MapPoint(
        latitude: village.latitude,
        longitude: village.longitude,
      ),
      zoom: 14,
    );
  }

  void _zoomBy(double delta) {
    final zoom = (_map.state.zoom + delta).clamp(minMapZoom, maxMapZoom);
    _map.control(zoom: zoom);
  }

  Map<String, dynamic> _officesGeoJson(List<OfficeLocationModel> offices) {
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final office in offices)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [office.longitude, office.latitude],
            },
            'properties': {
              'id': office.id,
              'name': office.name,
              'office_type': office.type,
              'contact_person_name': office.contactName,
              'contact_person_phone': office.contactPhone ?? '',
              'address': office.address,
              'district': office.district,
              'state': office.state,
            },
          },
      ],
    };
  }

  Map<String, dynamic> _areaLine(List<GeoPoint> points) {
    if (points.length < 2) return _emptyCollection;
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': [
              for (final point in points) [point.longitude, point.latitude],
            ],
          },
          'properties': const <String, dynamic>{},
        },
      ],
    };
  }

  Map<String, dynamic> _areaFill(List<GeoPoint> points) {
    if (points.length < 3) return _emptyCollection;
    final ring = [
      for (final point in points) [point.longitude, point.latitude],
    ];
    ring.add(ring.first);
    return {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'Polygon',
            'coordinates': [ring],
          },
          'properties': const <String, dynamic>{},
        },
      ],
    };
  }

  Map<String, dynamic> _areaPoints(List<GeoPoint> points) {
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final point in points)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [point.longitude, point.latitude],
            },
            'properties': const <String, dynamic>{},
          },
      ],
    };
  }
}

const _emptyCollection = <String, dynamic>{
  'type': 'FeatureCollection',
  'features': <dynamic>[],
};

class _StyleError extends StatelessWidget {
  const _StyleError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(PhosphorIconsRegular.warningCircle, size: 44),
            const SizedBox(height: 12),
            const Text('The map style could not be loaded.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
