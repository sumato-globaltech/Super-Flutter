import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/geo_map_geometry.dart';

import 'map_chrome.dart';

class GeoMapAreaCard extends StatelessWidget {
  const GeoMapAreaCard({
    required this.area,
    required this.onUndo,
    required this.onClear,
    required this.onClose,
    super.key,
  });

  final AreaDrawing area;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final squareMeters = polygonAreaSquareMeters(area.points);
    final hasArea = area.canMeasure;
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: MapChrome.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MapChrome.border),
        boxShadow: MapChrome.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsRegular.polygon,
                size: 18,
                color: MapChrome.accent,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area',
                      style: TextStyle(
                        color: MapChrome.content,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Tap the map to add vertices',
                      style: TextStyle(color: MapChrome.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(
                  Icons.close,
                  size: 17,
                  color: MapChrome.closeIcon,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: MapChrome.closeButton,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${area.points.length} vertices',
            style: const TextStyle(color: MapChrome.muted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          if (!hasArea)
            const Text(
              'Add at least 3 points to measure the area.',
              style: TextStyle(color: MapChrome.muted, fontSize: 12),
            )
          else ...[
            _AreaRow('Acres', formatAcres(squareMeters)),
            _AreaRow('Hectares', formatHectares(squareMeters)),
            if (squareMeters >= 1000000)
              _AreaRow('Square km', formatSquareKilometers(squareMeters)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: area.points.isEmpty ? null : onUndo,
                style: TextButton.styleFrom(foregroundColor: MapChrome.content),
                child: const Text('Undo'),
              ),
              TextButton(
                onPressed: area.points.isEmpty ? null : onClear,
                style: TextButton.styleFrom(foregroundColor: MapChrome.accent),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaRow extends StatelessWidget {
  const _AreaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: MapChrome.muted, fontSize: 11),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: MapChrome.content,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
