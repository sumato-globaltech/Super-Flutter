import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/geo_map/model/crop_suitability_model.dart';
import 'package:super_flutter/data/geo_map/model/district_info_model.dart';
import 'package:super_flutter/data/geo_map/model/office_location_model.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_models.dart';
import 'package:super_flutter/data/geo_map/model/weather_station_model.dart';

/// A WGS-84 point.
class GeoPoint extends Equatable {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

const defaultMapCenter = GeoPoint(latitude: 25.6751, longitude: 94.1086);
const defaultMapZoom = 7.0;
const minMapZoom = 4.0;
const maxMapZoom = 18.0;

enum GeoMapLayer {
  villages('villages', 'Villages', true),
  rivers('rivers', 'Rivers', true),
  weatherStations('weather_stations', 'Weather Stations', false),
  otherRoads('other_roads', 'Other Roads', false),
  nationalHighways('national_highways', 'National Highways', false),
  drainage('drainage', 'Drainage', false),
  hillPeaks('hill_peaks', 'Hill Peaks', false),
  adminHeadquarters('admin_hq', 'Administrative Headquarters', false),
  offices('geo_offices', 'Offices', false);

  const GeoMapLayer(this.layerId, this.label, this.defaultVisible);

  final String layerId;
  final String label;
  final bool defaultVisible;
}

const defaultVisibleLayers = {GeoMapLayer.villages, GeoMapLayer.rivers};

enum GeoMapCrop {
  avocado('Avocado', 'Avocado'),
  dragonFruit('DragonFruit', 'Dragon Fruit'),
  maize('Maize', 'Maize'),
  nagaMircha('NagaMircha', 'Naga Mircha'),
  palmOil('PalmOil', 'Palm Oil'),
  pineapple('Pineapple', 'Pineapple'),
  soyabean('Soyabean', 'Soyabean'),
  sugarcane('Sugarcane', 'Sugarcane'),
  turmeric('Turmeric', 'Turmeric'),
  banana('Banana', 'Banana'),
  coffee('Coffee', 'Coffee'),
  potato('Potato', 'Potato'),
  rajma('Rajma', 'Rajma'),
  rubber('Rubber', 'Rubber'),
  lemon('Lemon', 'Lemon'),
  stevia('Stevia', 'Stevia');

  const GeoMapCrop(this.path, this.label);

  final String path;
  final String label;

  String get layerId => 'crop_${path.toLowerCase()}';

  String get artworkAsset {
    final file = switch (this) {
      GeoMapCrop.dragonFruit => 'dragon_fruit',
      GeoMapCrop.nagaMircha => 'naga_mircha',
      GeoMapCrop.palmOil => 'palm_oil',
      _ => path.toLowerCase(),
    };
    return 'assets/geo_map/crops/$file.png';
  }
}

enum GeoMapTool { suitability, areaMeasurement }

enum MarkerTab { weather, suitability }

sealed class MapSelection extends Equatable {
  const MapSelection();
}

final class DistrictSelection extends MapSelection {
  const DistrictSelection(this.info);

  final DistrictInfoModel info;

  @override
  List<Object?> get props => [info];
}

final class VillageSelection extends MapSelection {
  const VillageSelection(this.village);

  final VillageModel village;

  @override
  List<Object?> get props => [village];
}

final class OfficeSelection extends MapSelection {
  const OfficeSelection(this.office);

  final OfficeLocationModel office;

  @override
  List<Object?> get props => [office];
}

final class WeatherStationSelection extends MapSelection {
  const WeatherStationSelection(this.station);

  final WeatherStationModel station;

  @override
  List<Object?> get props => [station];
}

sealed class MarkerData<T> extends Equatable {
  const MarkerData();
}

final class MarkerIdle<T> extends MarkerData<T> {
  const MarkerIdle();

  @override
  List<Object?> get props => const [];
}

final class MarkerLoading<T> extends MarkerData<T> {
  const MarkerLoading();

  @override
  List<Object?> get props => const [];
}

final class MarkerSuccess<T> extends MarkerData<T> {
  const MarkerSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class MarkerFailure<T> extends MarkerData<T> {
  const MarkerFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MarkerState extends Equatable {
  const MarkerState({
    required this.position,
    this.tab = MarkerTab.weather,
    this.weather = const MarkerIdle(),
    this.crops = const MarkerIdle(),
  });

  final GeoPoint position;
  final MarkerTab tab;
  final MarkerData<WeatherForecastModel> weather;
  final MarkerData<List<CropSuitabilityModel>> crops;

  MarkerState copyWith({
    MarkerTab? tab,
    MarkerData<WeatherForecastModel>? weather,
    MarkerData<List<CropSuitabilityModel>>? crops,
  }) {
    return MarkerState(
      position: position,
      tab: tab ?? this.tab,
      weather: weather ?? this.weather,
      crops: crops ?? this.crops,
    );
  }

  @override
  List<Object?> get props => [position, tab, weather, crops];
}

class AreaDrawing extends Equatable {
  const AreaDrawing({this.points = const []});

  final List<GeoPoint> points;

  bool get canMeasure => points.length >= 3;

  AreaDrawing add(GeoPoint point) => AreaDrawing(points: [...points, point]);

  AreaDrawing undo() => points.isEmpty
      ? this
      : AreaDrawing(points: points.sublist(0, points.length - 1));

  @override
  List<Object?> get props => [points];
}

class GeoMapState extends Equatable {
  const GeoMapState({
    this.visibleLayers = defaultVisibleLayers,
    this.visibleCrops = const {},
    this.selection,
    this.marker,
    this.area = const AreaDrawing(),
    this.offices = const [],
    this.villages = const [],
    this.villagesLoaded = false,
    this.searchQuery = '',
    this.layersExpanded = false,
    this.cropsExpanded = false,
    this.activeTool,
    this.message,
  });

  final Set<GeoMapLayer> visibleLayers;
  final Set<GeoMapCrop> visibleCrops;
  final MapSelection? selection;
  final MarkerState? marker;
  final AreaDrawing area;
  final List<OfficeLocationModel> offices;
  final List<VillageModel> villages;
  final bool villagesLoaded;
  final String searchQuery;
  final bool layersExpanded;
  final bool cropsExpanded;
  final GeoMapTool? activeTool;
  final String? message;

  bool isLayerVisible(GeoMapLayer layer) => visibleLayers.contains(layer);

  List<VillageModel> get searchResults {
    final query = searchQuery.trim();
    if (query.isEmpty) return const [];
    final matches = villages
        .where(
          (village) => village.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList(growable: false);
    matches.sort((a, b) {
      final aStarts = a.name.toLowerCase().startsWith(query.toLowerCase());
      final bStarts = b.name.toLowerCase().startsWith(query.toLowerCase());
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matches.take(8).toList(growable: false);
  }

  GeoMapState copyWith({
    Set<GeoMapLayer>? visibleLayers,
    Set<GeoMapCrop>? visibleCrops,
    Object? selection = _unset,
    Object? marker = _unset,
    AreaDrawing? area,
    List<OfficeLocationModel>? offices,
    List<VillageModel>? villages,
    bool? villagesLoaded,
    String? searchQuery,
    bool? layersExpanded,
    bool? cropsExpanded,
    Object? activeTool = _unset,
    Object? message = _unset,
  }) {
    return GeoMapState(
      visibleLayers: visibleLayers ?? this.visibleLayers,
      visibleCrops: visibleCrops ?? this.visibleCrops,
      selection: identical(selection, _unset)
          ? this.selection
          : selection as MapSelection?,
      marker: identical(marker, _unset) ? this.marker : marker as MarkerState?,
      area: area ?? this.area,
      offices: offices ?? this.offices,
      villages: villages ?? this.villages,
      villagesLoaded: villagesLoaded ?? this.villagesLoaded,
      searchQuery: searchQuery ?? this.searchQuery,
      layersExpanded: layersExpanded ?? this.layersExpanded,
      cropsExpanded: cropsExpanded ?? this.cropsExpanded,
      activeTool: identical(activeTool, _unset)
          ? this.activeTool
          : activeTool as GeoMapTool?,
      message: identical(message, _unset) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => [
    visibleLayers,
    visibleCrops,
    selection,
    marker,
    area,
    offices,
    villages,
    villagesLoaded,
    searchQuery,
    layersExpanded,
    cropsExpanded,
    activeTool,
    message,
  ];
}

const _unset = Object();
