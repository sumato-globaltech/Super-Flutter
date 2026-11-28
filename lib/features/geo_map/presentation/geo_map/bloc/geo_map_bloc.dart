import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/data/geo_map/model/crop_suitability_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_models.dart';
import 'package:super_flutter/data/geo_map/sources/remote/geo_map_remote_data_source.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_event.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

@injectable
class GeoMapBloc extends Bloc<GeoMapEvent, GeoMapState> {
  GeoMapBloc(this._remoteDataSource) : super(const GeoMapState()) {
    on<GeoMapStarted>(_onStarted);
    on<GeoMapRetried>(_onRetried);
    on<GeoMapLayerToggled>(_onLayerToggled);
    on<GeoMapLayersTrayToggled>(_onLayersTrayToggled);
    on<GeoMapCropsTrayToggled>(_onCropsTrayToggled);
    on<GeoMapCropToggled>(_onCropToggled);
    on<GeoMapToolToggled>(_onToolToggled);
    on<GeoMapTapped>(_onMapTapped);
    on<GeoMapMarkerTabSelected>(_onMarkerTabSelected);
    on<GeoMapMarkerRetried>(_onMarkerRetried);
    on<GeoMapMarkerCleared>(_onMarkerCleared);
    on<GeoMapAreaPointUndone>(_onAreaPointUndone);
    on<GeoMapAreaCleared>(_onAreaCleared);
    on<GeoMapAreaClosed>(_onAreaClosed);
    on<GeoMapSearchQueryChanged>(_onSearchQueryChanged);
    on<GeoMapVillageSearched>(_onVillageSearched);
    on<GeoMapDistrictSelected>(_onDistrictSelected);
    on<GeoMapOfficeSelected>(_onOfficeSelected);
    on<GeoMapWeatherStationSelected>(_onWeatherStationSelected);
    on<GeoMapSelectionCleared>(_onSelectionCleared);
    on<GeoMapMessageShown>(_onMessageShown);
  }

  final GeoMapRemoteDataSource _remoteDataSource;

  Future<void> _onStarted(
    GeoMapStarted event,
    Emitter<GeoMapState> emit,
  ) async {
    await Future.wait([_loadVillages(emit), _loadOffices(emit)]);
  }

  Future<void> _onRetried(
    GeoMapRetried event,
    Emitter<GeoMapState> emit,
  ) async {
    emit(state.copyWith(message: null));
    await Future.wait([_loadVillages(emit), _loadOffices(emit)]);
  }

  Future<void> _loadVillages(Emitter<GeoMapState> emit) async {
    if (state.villagesLoaded) return;
    try {
      final villages = await _remoteDataSource.getVillages();
      emit(state.copyWith(villages: villages, villagesLoaded: true));
    } catch (_) {
      emit(state.copyWith(message: 'Could not load the village search data.'));
    }
  }

  Future<void> _loadOffices(Emitter<GeoMapState> emit) async {
    try {
      final offices = await _remoteDataSource.getOffices();
      emit(state.copyWith(offices: offices));
    } catch (_) {
      emit(state.copyWith(message: 'Could not load the office locations.'));
    }
  }

  void _onLayerToggled(GeoMapLayerToggled event, Emitter<GeoMapState> emit) {
    final layers = {...state.visibleLayers};
    if (!layers.add(event.layer)) layers.remove(event.layer);
    emit(state.copyWith(visibleLayers: layers));
  }

  void _onLayersTrayToggled(
    GeoMapLayersTrayToggled event,
    Emitter<GeoMapState> emit,
  ) {
    emit(
      state.copyWith(
        layersExpanded: !state.layersExpanded,
        cropsExpanded: false,
      ),
    );
  }

  void _onCropsTrayToggled(
    GeoMapCropsTrayToggled event,
    Emitter<GeoMapState> emit,
  ) {
    emit(
      state.copyWith(
        cropsExpanded: !state.cropsExpanded,
        layersExpanded: false,
      ),
    );
  }

  void _onCropToggled(GeoMapCropToggled event, Emitter<GeoMapState> emit) {
    final crops = {...state.visibleCrops};
    if (!crops.add(event.crop)) crops.remove(event.crop);
    emit(state.copyWith(visibleCrops: crops));
  }

  void _onToolToggled(GeoMapToolToggled event, Emitter<GeoMapState> emit) {
    final next = state.activeTool == event.tool ? null : event.tool;
    emit(
      state.copyWith(
        activeTool: next,
        marker: next == GeoMapTool.suitability ? state.marker : null,
        selection: next == GeoMapTool.areaMeasurement ? null : state.selection,
        area: next == GeoMapTool.areaMeasurement
            ? const AreaDrawing()
            : state.area,
      ),
    );
  }

  Future<void> _onMapTapped(
    GeoMapTapped event,
    Emitter<GeoMapState> emit,
  ) async {
    switch (state.activeTool) {
      case GeoMapTool.suitability:
        final marker = MarkerState(position: event.point);
        emit(state.copyWith(selection: null, marker: marker));
        await _loadWeather(event.point, emit, force: true);
      case GeoMapTool.areaMeasurement:
        emit(state.copyWith(area: state.area.add(event.point)));
      case null:
        break;
    }
  }

  Future<void> _onMarkerTabSelected(
    GeoMapMarkerTabSelected event,
    Emitter<GeoMapState> emit,
  ) async {
    final marker = state.marker;
    if (marker == null) return;
    emit(state.copyWith(marker: marker.copyWith(tab: event.tab)));
    switch (event.tab) {
      case MarkerTab.weather:
        await _loadWeather(marker.position, emit);
      case MarkerTab.suitability:
        await _loadSuitability(marker.position, emit);
    }
  }

  Future<void> _onMarkerRetried(
    GeoMapMarkerRetried event,
    Emitter<GeoMapState> emit,
  ) async {
    final marker = state.marker;
    if (marker == null) return;
    switch (marker.tab) {
      case MarkerTab.weather:
        await _loadWeather(marker.position, emit, force: true);
      case MarkerTab.suitability:
        await _loadSuitability(marker.position, emit, force: true);
    }
  }

  void _onMarkerCleared(GeoMapMarkerCleared event, Emitter<GeoMapState> emit) {
    emit(state.copyWith(marker: null, activeTool: null));
  }

  void _onAreaPointUndone(
    GeoMapAreaPointUndone event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(area: state.area.undo()));
  }

  void _onAreaCleared(GeoMapAreaCleared event, Emitter<GeoMapState> emit) {
    emit(state.copyWith(area: const AreaDrawing()));
  }

  void _onAreaClosed(GeoMapAreaClosed event, Emitter<GeoMapState> emit) {
    emit(state.copyWith(area: const AreaDrawing(), activeTool: null));
  }

  void _onSearchQueryChanged(
    GeoMapSearchQueryChanged event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onVillageSearched(
    GeoMapVillageSearched event,
    Emitter<GeoMapState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: '',
        selection: VillageSelection(event.village),
        marker: null,
        activeTool: null,
      ),
    );
  }

  void _onDistrictSelected(
    GeoMapDistrictSelected event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(selection: DistrictSelection(event.district)));
  }

  void _onOfficeSelected(
    GeoMapOfficeSelected event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(selection: OfficeSelection(event.office)));
  }

  void _onWeatherStationSelected(
    GeoMapWeatherStationSelected event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(selection: WeatherStationSelection(event.station)));
  }

  void _onSelectionCleared(
    GeoMapSelectionCleared event,
    Emitter<GeoMapState> emit,
  ) {
    emit(state.copyWith(selection: null));
  }

  void _onMessageShown(GeoMapMessageShown event, Emitter<GeoMapState> emit) {
    emit(state.copyWith(message: null));
  }

  Future<void> _loadWeather(
    GeoPoint position,
    Emitter<GeoMapState> emit, {
    bool force = false,
  }) async {
    final marker = state.marker;
    if (marker == null || marker.position != position) return;
    if (!force && marker.weather is MarkerSuccess<WeatherForecastModel>) {
      return;
    }
    emit(
      state.copyWith(
        marker: marker.copyWith(
          weather: const MarkerLoading<WeatherForecastModel>(),
        ),
      ),
    );
    try {
      final forecast = await _remoteDataSource.getWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (state.marker?.position != position) return;
      emit(
        state.copyWith(
          marker: state.marker!.copyWith(
            weather: MarkerSuccess<WeatherForecastModel>(forecast),
          ),
        ),
      );
    } catch (_) {
      if (state.marker?.position != position) return;
      emit(
        state.copyWith(
          marker: state.marker!.copyWith(
            weather: const MarkerFailure<WeatherForecastModel>(
              'Could not load the weather forecast',
            ),
          ),
          message: 'Could not load the weather forecast',
        ),
      );
    }
  }

  Future<void> _loadSuitability(
    GeoPoint position,
    Emitter<GeoMapState> emit, {
    bool force = false,
  }) async {
    final marker = state.marker;
    if (marker == null || marker.position != position) return;
    if (!force && marker.crops is MarkerSuccess<List<CropSuitabilityModel>>) {
      return;
    }
    emit(
      state.copyWith(
        marker: marker.copyWith(
          crops: const MarkerLoading<List<CropSuitabilityModel>>(),
        ),
      ),
    );
    try {
      final crops = await _remoteDataSource.getSuitability(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (state.marker?.position != position) return;
      emit(
        state.copyWith(
          marker: state.marker!.copyWith(
            crops: MarkerSuccess<List<CropSuitabilityModel>>(crops),
          ),
        ),
      );
    } catch (_) {
      if (state.marker?.position != position) return;
      emit(
        state.copyWith(
          marker: state.marker!.copyWith(
            crops: const MarkerFailure<List<CropSuitabilityModel>>(
              'Could not load crop suitability',
            ),
          ),
          message: 'Could not load crop suitability',
        ),
      );
    }
  }
}
