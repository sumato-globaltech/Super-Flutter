import 'package:material_ui/material_ui.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

import 'map_chrome.dart';

class GeoMapCropTray extends StatelessWidget {
  const GeoMapCropTray({
    required this.visibleCrops,
    required this.onToggle,
    super.key,
  });

  final Set<GeoMapCrop> visibleCrops;
  final ValueChanged<GeoMapCrop> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 360),
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
              'Crop suitability',
              style: TextStyle(
                color: MapChrome.content,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final crop in GeoMapCrop.values)
                    _CropChip(
                      crop: crop,
                      selected: visibleCrops.contains(crop),
                      onTap: () => onToggle(crop),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropChip extends StatelessWidget {
  const _CropChip({
    required this.crop,
    required this.selected,
    required this.onTap,
  });

  final GeoMapCrop crop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MapChrome.tile : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? MapChrome.accent : MapChrome.border,
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                crop.artworkAsset,
                width: 24,
                height: 24,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.eco_outlined,
                  size: 22,
                  color: MapChrome.muted,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  crop.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? MapChrome.content : MapChrome.muted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
