import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/data/geo_map/model/crop_suitability_model.dart';
import 'package:super_flutter/data/geo_map/model/weather_models.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

import 'map_chrome.dart';

class GeoMapMarkerCard extends StatelessWidget {
  const GeoMapMarkerCard({
    required this.marker,
    required this.onTabSelected,
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  final MarkerState marker;
  final ValueChanged<MarkerTab> onTabSelected;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: MapChrome.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MapChrome.border),
        boxShadow: MapChrome.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Point analysis',
                        style: TextStyle(
                          color: MapChrome.content,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Tap another point to move the marker',
                        style: TextStyle(color: MapChrome.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: MapChrome.closeIcon,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: MapChrome.closeButton,
                    minimumSize: const Size(30, 30),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _TabButton(
                  label: 'Weather Report',
                  selected: marker.tab == MarkerTab.weather,
                  onTap: () => onTabSelected(MarkerTab.weather),
                ),
                const SizedBox(width: 6),
                _TabButton(
                  label: 'Crop Suitability',
                  selected: marker.tab == MarkerTab.suitability,
                  onTap: () => onTabSelected(MarkerTab.suitability),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: MapChrome.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: switch (marker.tab) {
                MarkerTab.weather => _WeatherBody(
                  data: marker.weather,
                  onRetry: onRetry,
                ),
                MarkerTab.suitability => _CropsBody(
                  data: marker.crops,
                  onRetry: onRetry,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? MapChrome.tile : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? MapChrome.accent : MapChrome.border,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? MapChrome.content : MapChrome.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherBody extends StatelessWidget {
  const _WeatherBody({required this.data, required this.onRetry});

  final MarkerData<WeatherForecastModel> data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (data) {
      MarkerIdle() ||
      MarkerLoading() => const _Loading(label: 'Loading the weather forecast…'),
      MarkerFailure(:final message) => _Error(
        message: message,
        onRetry: onRetry,
      ),
      MarkerSuccess(:final data) => _Forecast(forecast: data),
    };
  }
}

class _Forecast extends StatelessWidget {
  const _Forecast({required this.forecast});

  final WeatherForecastModel forecast;

  @override
  Widget build(BuildContext context) {
    final current = forecast.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MapChrome.tile,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _weatherIcon(current.icon),
                size: 38,
                color: MapChrome.accentYellow,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperatureC.round()}°C · feels like '
                      '${current.feelsLikeC.round()}°C',
                      style: const TextStyle(
                        color: MapChrome.content,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      current.description.isEmpty
                          ? forecast.locationName
                          : current.description,
                      style: const TextStyle(
                        color: MapChrome.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniStat('Humidity', '${current.humidity}%'),
                        const SizedBox(width: 14),
                        _MiniStat('Wind', '${current.windSpeed.round()} m/s'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (forecast.days.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Next days',
            style: TextStyle(
              color: MapChrome.content,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final day in forecast.days) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: MapChrome.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dayLabel(day.dateIso),
                      style: const TextStyle(
                        color: MapChrome.content,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _weatherIcon(day.icon),
                    size: 18,
                    color: MapChrome.accentYellow,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${day.minTemperatureC.round()}° / '
                    '${day.maxTemperatureC.round()}°',
                    style: const TextStyle(
                      color: MapChrome.content,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(day.precipitationChance * 100).round()}% rain',
                    style: const TextStyle(
                      color: MapChrome.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  IconData _weatherIcon(String code) {
    if (code.startsWith('09') || code.startsWith('10')) {
      return Icons.grain;
    }
    if (code.startsWith('11')) return Icons.thunderstorm_outlined;
    if (code.startsWith('13')) return Icons.ac_unit;
    if (code.startsWith('50')) return Icons.foggy;
    if (code.startsWith('01')) return Icons.wb_sunny_outlined;
    if (code.startsWith('02') || code.startsWith('03')) {
      return Icons.cloud_outlined;
    }
    return Icons.cloud_queue;
  }

  String _dayLabel(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _CropsBody extends StatelessWidget {
  const _CropsBody({required this.data, required this.onRetry});

  final MarkerData<List<CropSuitabilityModel>> data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (data) {
      MarkerIdle() ||
      MarkerLoading() => const _Loading(label: 'Evaluating crop suitability…'),
      MarkerFailure(:final message) => _Error(
        message: message,
        onRetry: onRetry,
      ),
      MarkerSuccess(:final data) =>
        data.isEmpty
            ? const Text(
                'No crops were evaluated for this point.',
                style: TextStyle(color: MapChrome.muted, fontSize: 12),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final crop in data) _CropRow(crop: crop)],
              ),
    };
  }
}

class _CropRow extends StatelessWidget {
  const _CropRow({required this.crop});

  final CropSuitabilityModel crop;

  @override
  Widget build(BuildContext context) {
    final band = _band(crop.percent);
    final asset = _artwork(crop.key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: asset == null
                ? const Icon(Icons.eco_outlined, color: MapChrome.muted)
                : Image.asset(
                    asset,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.eco_outlined, color: MapChrome.muted),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        crop.label,
                        style: const TextStyle(
                          color: MapChrome.content,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${crop.percent.round()}%',
                      style: const TextStyle(
                        color: MapChrome.content,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (crop.percent / 100).clamp(0, 1),
                    minHeight: 5,
                    backgroundColor: MapChrome.tile,
                    valueColor: AlwaysStoppedAnimation(band.color),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  band.label,
                  style: TextStyle(color: band.color, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _band(double percent) {
    if (percent < 20) {
      return (label: 'Not Suitable', color: const Color(0xFFE02F0A));
    }
    if (percent < 40) {
      return (label: 'Marginally Suitable', color: const Color(0xFFF76F0F));
    }
    if (percent < 60) {
      return (label: 'Moderately Suitable', color: const Color(0xFFD9B627));
    }
    if (percent < 80) {
      return (label: 'Suitable', color: const Color(0xFF2F9C26));
    }
    return (label: 'Highly Suitable', color: const Color(0xFF00441B));
  }

  String? _artwork(String key) {
    final path = switch (key) {
      'Avocado' => 'avocado',
      'DragonFruit' => 'dragon_fruit',
      'Maize' => 'maize',
      'NagaMircha' => 'naga_mircha',
      'PalmOil' => 'palm_oil',
      'Pineapple' => 'pineapple',
      'Soyabean' => 'soyabean',
      'Sugarcane' => 'sugarcane',
      'Turmeric' => 'turmeric',
      'Banana' => 'banana',
      'Coffee' => 'coffee',
      'Potato' => 'potato',
      'Rajma' => 'rajma',
      'Rubber' => 'rubber',
      'Lemon' => 'lemon',
      'Stevia' => 'stevia',
      _ => null,
    };
    return path == null ? null : 'assets/geo_map/crops/$path.png';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: MapChrome.muted, fontSize: 9),
        ),
        Text(
          value,
          style: const TextStyle(
            color: MapChrome.content,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MapChrome.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: MapChrome.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: MapChrome.accent),
          child: const Text('Try again'),
        ),
      ],
    );
  }
}
