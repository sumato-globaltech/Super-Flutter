import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

import 'map_chrome.dart';

class GeoMapLayerTray extends StatelessWidget {
  const GeoMapLayerTray({
    required this.visibleLayers,
    required this.onToggle,
    super.key,
  });

  final Set<GeoMapLayer> visibleLayers;
  final ValueChanged<GeoMapLayer> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Map layers',
              style: TextStyle(
                color: MapChrome.content,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final layer in GeoMapLayer.values)
                  _LayerRow(
                    layer: layer,
                    selected: visibleLayers.contains(layer),
                    onToggle: () => onToggle(layer),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  const _LayerRow({
    required this.layer,
    required this.selected,
    required this.onToggle,
  });

  final GeoMapLayer layer;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Icon(
              _iconFor(layer),
              size: 18,
              color: selected ? MapChrome.accent : MapChrome.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                layer.label,
                style: const TextStyle(color: MapChrome.content, fontSize: 13),
              ),
            ),
            Switch.adaptive(
              value: selected,
              activeTrackColor: MapChrome.accent,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(GeoMapLayer layer) => switch (layer) {
    GeoMapLayer.villages => PhosphorIconsRegular.house,
    GeoMapLayer.rivers => PhosphorIconsRegular.waves,
    GeoMapLayer.weatherStations => PhosphorIconsRegular.cloudSun,
    GeoMapLayer.otherRoads => PhosphorIconsRegular.path,
    GeoMapLayer.nationalHighways => PhosphorIconsRegular.roadHorizon,
    GeoMapLayer.drainage => PhosphorIconsRegular.drop,
    GeoMapLayer.hillPeaks => PhosphorIconsRegular.mountains,
    GeoMapLayer.adminHeadquarters => PhosphorIconsRegular.buildings,
    GeoMapLayer.offices => PhosphorIconsRegular.officeChair,
  };
}
