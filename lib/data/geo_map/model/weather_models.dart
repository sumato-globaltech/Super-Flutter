import 'package:equatable/equatable.dart';

class WeatherForecastModel extends Equatable {
  const WeatherForecastModel({
    required this.locationName,
    required this.country,
    required this.current,
    required this.days,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final list = (json['list'] as List?) ?? const [];
    if (list.isEmpty) {
      throw const FormatException('The weather service returned no forecast');
    }
    final entries = list
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList(growable: false);
    if (entries.isEmpty) {
      throw const FormatException('The weather service returned no forecast');
    }

    String dateOf(Map<String, dynamic> item) =>
        '${item['dt_txt'] ?? ''}'.split(' ').first;

    final first = entries.first;
    final currentDate = dateOf(first);
    final current = CurrentWeatherModel.fromJson(first);

    final byDate = <String, List<Map<String, dynamic>>>{};
    for (final entry in entries) {
      final date = dateOf(entry);
      if (date.isEmpty || date == currentDate) continue;
      byDate.putIfAbsent(date, () => []).add(entry);
    }

    final days =
        byDate.entries
            .map(
              (entry) => DailyWeatherModel.fromEntries(entry.key, entry.value),
            )
            .toList(growable: false)
          ..sort((a, b) => a.dateIso.compareTo(b.dateIso));

    final city =
        (json['city'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return WeatherForecastModel(
      locationName: '${city['name'] ?? ''}',
      country: '${city['country'] ?? ''}',
      current: current,
      days: days.take(5).toList(growable: false),
    );
  }

  final String locationName;
  final String country;
  final CurrentWeatherModel current;
  final List<DailyWeatherModel> days;

  @override
  List<Object?> get props => [locationName, country, current, days];
}

class CurrentWeatherModel extends Equatable {
  const CurrentWeatherModel({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibilityMeters,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> item) {
    final main =
        (item['main'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final weather = ((item['weather'] as List?) ?? const [])
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .toList(growable: false);
    final wind =
        (item['wind'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return CurrentWeatherModel(
      temperatureC: _number(main['temp']) ?? 0,
      feelsLikeC: _number(main['feels_like']) ?? 0,
      description: weather.isEmpty
          ? ''
          : '${weather.first['description'] ?? ''}',
      icon: weather.isEmpty ? '01d' : '${weather.first['icon'] ?? '01d'}',
      humidity: (_number(main['humidity']) ?? 0).round(),
      windSpeed: _number(wind['speed']) ?? 0,
      pressure: _number(main['pressure']) ?? 0,
      visibilityMeters: (_number(item['visibility']) ?? 0).round(),
    );
  }

  final double temperatureC;
  final double feelsLikeC;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final int visibilityMeters;

  @override
  List<Object?> get props => [temperatureC, feelsLikeC, description, icon];
}

class DailyWeatherModel extends Equatable {
  const DailyWeatherModel({
    required this.dateIso,
    required this.minTemperatureC,
    required this.maxTemperatureC,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationChance,
  });

  factory DailyWeatherModel.fromEntries(
    String date,
    List<Map<String, dynamic>> entries,
  ) {
    final first = entries.first;
    final main =
        (first['main'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final weather = ((first['weather'] as List?) ?? const [])
        .whereType<Map>()
        .map((entry) => entry.cast<String, dynamic>())
        .toList(growable: false);
    final wind =
        (first['wind'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    var minTemp = double.infinity;
    var maxTemp = double.negativeInfinity;
    var precipitation = 0.0;
    for (final entry in entries) {
      final itemMain =
          (entry['main'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      final low = _number(itemMain['temp_min']);
      final high = _number(itemMain['temp_max']);
      if (low != null && low < minTemp) minTemp = low;
      if (high != null && high > maxTemp) maxTemp = high;
      final pop = _number(entry['pop']);
      if (pop != null && pop > precipitation) precipitation = pop;
    }

    return DailyWeatherModel(
      dateIso: date,
      minTemperatureC: minTemp.isFinite ? minTemp : 0,
      maxTemperatureC: maxTemp.isFinite ? maxTemp : 0,
      description: weather.isEmpty
          ? ''
          : '${weather.first['description'] ?? ''}',
      icon: weather.isEmpty ? '01d' : '${weather.first['icon'] ?? '01d'}',
      humidity: (_number(main['humidity']) ?? 0).round(),
      windSpeed: _number(wind['speed']) ?? 0,
      precipitationChance: precipitation,
    );
  }

  final String dateIso;
  final double minTemperatureC;
  final double maxTemperatureC;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double precipitationChance;

  @override
  List<Object?> get props => [dateIso, minTemperatureC, maxTemperatureC];
}

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}
