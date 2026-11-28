import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/geo_map/model/district_info_model.dart';
import 'package:super_flutter/data/geo_map/model/office_location_model.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_station_model.dart';

import 'geo_map_state.dart';

sealed class GeoMapEvent extends Equatable {
  const GeoMapEvent();

  @override
  List<Object?> get props => const [];
}

final class GeoMapStarted extends GeoMapEvent {
  const GeoMapStarted();
}

final class GeoMapRetried extends GeoMapEvent {
  const GeoMapRetried();
}

final class GeoMapLayerToggled extends GeoMapEvent {
  const GeoMapLayerToggled(this.layer);

  final GeoMapLayer layer;

  @override
  List<Object?> get props => [layer];
}

final class GeoMapLayersTrayToggled extends GeoMapEvent {
  const GeoMapLayersTrayToggled();
}

final class GeoMapCropsTrayToggled extends GeoMapEvent {
  const GeoMapCropsTrayToggled();
}

final class GeoMapCropToggled extends GeoMapEvent {
  const GeoMapCropToggled(this.crop);

  final GeoMapCrop crop;

  @override
  List<Object?> get props => [crop];
}

final class GeoMapToolToggled extends GeoMapEvent {
  const GeoMapToolToggled(this.tool);

  final GeoMapTool tool;

  @override
  List<Object?> get props => [tool];
}

final class GeoMapTapped extends GeoMapEvent {
  const GeoMapTapped(this.point);

  final GeoPoint point;

  @override
  List<Object?> get props => [point];
}

final class GeoMapMarkerTabSelected extends GeoMapEvent {
  const GeoMapMarkerTabSelected(this.tab);

  final MarkerTab tab;

  @override
  List<Object?> get props => [tab];
}

final class GeoMapMarkerRetried extends GeoMapEvent {
  const GeoMapMarkerRetried();
}

final class GeoMapMarkerCleared extends GeoMapEvent {
  const GeoMapMarkerCleared();
}

final class GeoMapAreaPointUndone extends GeoMapEvent {
  const GeoMapAreaPointUndone();
}

final class GeoMapAreaCleared extends GeoMapEvent {
  const GeoMapAreaCleared();
}

final class GeoMapAreaClosed extends GeoMapEvent {
  const GeoMapAreaClosed();
}

final class GeoMapSearchQueryChanged extends GeoMapEvent {
  const GeoMapSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class GeoMapVillageSearched extends GeoMapEvent {
  const GeoMapVillageSearched(this.village);

  final VillageModel village;

  @override
  List<Object?> get props => [village];
}

final class GeoMapDistrictSelected extends GeoMapEvent {
  const GeoMapDistrictSelected(this.district);

  final DistrictInfoModel district;

  @override
  List<Object?> get props => [district];
}

final class GeoMapOfficeSelected extends GeoMapEvent {
  const GeoMapOfficeSelected(this.office);

  final OfficeLocationModel office;

  @override
  List<Object?> get props => [office];
}

final class GeoMapWeatherStationSelected extends GeoMapEvent {
  const GeoMapWeatherStationSelected(this.station);

  final WeatherStationModel station;

  @override
  List<Object?> get props => [station];
}

final class GeoMapSelectionCleared extends GeoMapEvent {
  const GeoMapSelectionCleared();
}

final class GeoMapMessageShown extends GeoMapEvent {
  const GeoMapMessageShown();
}
