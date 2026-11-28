import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/core/utils/utils.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

import 'map_chrome.dart';

class GeoMapDetailsCard extends StatelessWidget {
  const GeoMapDetailsCard({
    required this.selection,
    required this.onClose,
    super.key,
  });

  final MapSelection selection;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon, rows) = _content();
    return Container(
      width: 330,
      constraints: const BoxConstraints(maxHeight: 460),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: MapChrome.tile,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: MapChrome.accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MapChrome.content,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MapChrome.muted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                _CloseButton(onPressed: onClose),
              ],
            ),
          ),
          const Divider(height: 1, color: MapChrome.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final row in rows) ...[
                    _DetailRow(row: row),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String, String?, IconData, List<_DetailRowData>) _content() {
    return switch (selection) {
      DistrictSelection(:final info) => (
        info.name,
        'District',
        PhosphorIconsRegular.mapTrifold,
        [
          _DetailRowData('Area', _value(info.areaSqKm, 'km²')),
          _DetailRowData('Population', info.population?.toString() ?? '—'),
          _DetailRowData('Villages', info.villageCount?.toString() ?? '—'),
          _DetailRowData('Cropland', _value(info.croplandHa, 'ha')),
          _DetailRowData('Forest', _value(info.forestHa, 'ha')),
          _DetailRowData('Barren', _value(info.barrenHa, 'ha')),
          _DetailRowData('Built-up', _value(info.builtUpHa, 'ha')),
        ],
      ),
      VillageSelection(:final village) => (
        village.name,
        village.district.isEmpty ? 'Village' : village.district,
        PhosphorIconsRegular.mapPin,
        [
          _DetailRowData(
            'Latitude',
            village.latitude.toStringAsFixed(6),
            mono: true,
          ),
          _DetailRowData(
            'Longitude',
            village.longitude.toStringAsFixed(6),
            mono: true,
          ),
          if (village.latitudeDms.isNotEmpty)
            _DetailRowData('Latitude (DMS)', village.latitudeDms, mono: true),
          if (village.longitudeDms.isNotEmpty)
            _DetailRowData('Longitude (DMS)', village.longitudeDms, mono: true),
        ],
      ),
      OfficeSelection(:final office) => (
        office.name,
        office.type.isEmpty ? 'Office' : office.type,
        PhosphorIconsRegular.buildings,
        [
          _DetailRowData(
            'Contact',
            office.contactName.isEmpty ? '—' : office.contactName,
          ),
          _DetailRowData(
            'Phone',
            office.contactPhone ?? '—',
            onTap: office.contactPhone == null
                ? null
                : () => Utils.launchUrl2(url: 'tel:${office.contactPhone}'),
          ),
          _DetailRowData(
            'Address',
            office.address.isEmpty ? '—' : office.address,
          ),
          _DetailRowData(
            'District',
            office.district.isEmpty ? '—' : office.district,
          ),
          _DetailRowData('State', office.state.isEmpty ? '—' : office.state),
        ],
      ),
      WeatherStationSelection(:final station) => (
        station.district.isEmpty ? 'Weather station' : station.district,
        'Weather station',
        PhosphorIconsRegular.cloudSun,
        [
          ..._weatherRows(station.attributes),
          _DetailRowData(
            'Latitude',
            station.latitude.toStringAsFixed(6),
            mono: true,
          ),
          _DetailRowData(
            'Longitude',
            station.longitude.toStringAsFixed(6),
            mono: true,
          ),
        ],
      ),
    };
  }

  List<_DetailRowData> _weatherRows(Map<String, String> attributes) {
    const labels = {
      'tempr': 'Temperature',
      'rain': 'Rain',
      'wind': 'Wind',
      'humdty': 'Humidity',
      'pressure': 'Pressure',
    };
    const units = {
      'tempr': '°C',
      'rain': '%',
      'wind': 'km/h',
      'humdty': '%',
      'pressure': 'hPa',
    };
    const metadata = {
      'id',
      'dist_name',
      'lat',
      'long',
      'Latitude',
      'Longitude',
    };
    const order = ['tempr', 'rain', 'wind', 'humdty', 'pressure'];
    final keys =
        attributes.keys
            .where(
              (key) => !metadata.contains(key) && attributes[key]!.isNotEmpty,
            )
            .toList()
          ..sort((a, b) {
            final ai = order.indexOf(a);
            final bi = order.indexOf(b);
            if (ai == -1 && bi == -1) return a.compareTo(b);
            if (ai == -1) return 1;
            if (bi == -1) return -1;
            return ai.compareTo(bi);
          });
    return [
      for (final key in keys)
        _DetailRowData(
          labels[key] ?? key,
          '${attributes[key]}${units[key] == null ? '' : ' ${units[key]}'}',
        ),
    ];
  }

  String _value(double? value, String unit) =>
      value == null ? '—' : '${value.toInt()} $unit';
}

class _DetailRowData {
  const _DetailRowData(this.label, this.value, {this.mono = false, this.onTap});

  final String label;
  final String value;
  final bool mono;
  final VoidCallback? onTap;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row});

  final _DetailRowData row;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      row.value,
      textAlign: TextAlign.end,
      style: TextStyle(
        color: row.onTap == null ? MapChrome.content : MapChrome.accent,
        fontSize: 12,
        fontFamily: row.mono ? 'monospace' : null,
        fontWeight: FontWeight.w600,
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            row.label,
            style: const TextStyle(color: MapChrome.muted, fontSize: 11),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: row.onTap == null
              ? Align(alignment: Alignment.centerRight, child: text)
              : GestureDetector(onTap: row.onTap, child: text),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Close',
      icon: const Icon(Icons.close, size: 18, color: MapChrome.closeIcon),
      style: IconButton.styleFrom(
        backgroundColor: MapChrome.closeButton,
        minimumSize: const Size(30, 30),
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
    );
  }
}
