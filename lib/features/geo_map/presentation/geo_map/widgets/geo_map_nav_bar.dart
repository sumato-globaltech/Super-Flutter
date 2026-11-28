import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:super_flutter/data/geo_map/model/village_model.dart';
import 'package:super_flutter/features/geo_map/presentation/geo_map/bloc/geo_map_state.dart';

import 'map_chrome.dart';

class GeoMapNavBar extends StatefulWidget {
  const GeoMapNavBar({
    required this.query,
    required this.results,
    required this.villagesLoaded,
    required this.zoom,
    required this.activeTool,
    required this.layersExpanded,
    required this.cropsExpanded,
    required this.onQueryChanged,
    required this.onVillageSelected,
    required this.onToggleLayers,
    required this.onToggleCrops,
    required this.onToggleTool,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetCamera,
    required this.onBack,
    super.key,
  });

  final String query;
  final List<VillageModel> results;
  final bool villagesLoaded;
  final double zoom;
  final GeoMapTool? activeTool;
  final bool layersExpanded;
  final bool cropsExpanded;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<VillageModel> onVillageSelected;
  final VoidCallback onToggleLayers;
  final VoidCallback onToggleCrops;
  final ValueChanged<GeoMapTool> onToggleTool;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetCamera;
  final VoidCallback onBack;

  @override
  State<GeoMapNavBar> createState() => _GeoMapNavBarState();
}

class _GeoMapNavBarState extends State<GeoMapNavBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(covariant GeoMapNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _RoundButton(
                  icon: PhosphorIconsRegular.arrowLeft,
                  tooltip: 'Back',
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: 8),
                _BrandPill(showName: wide),
                const SizedBox(width: 8),
                Expanded(child: _buildSearch()),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolButton(
                    icon: PhosphorIconsRegular.stack,
                    label: 'Layers',
                    showLabel: wide,
                    active: widget.layersExpanded,
                    onPressed: widget.onToggleLayers,
                  ),
                  _ToolButton(
                    icon: PhosphorIconsRegular.plant,
                    label: 'Crops',
                    showLabel: wide,
                    active: widget.cropsExpanded,
                    onPressed: widget.onToggleCrops,
                  ),
                  _ToolButton(
                    icon: PhosphorIconsRegular.leaf,
                    label: 'Suitability',
                    showLabel: wide,
                    active: widget.activeTool == GeoMapTool.suitability,
                    onPressed: () =>
                        widget.onToggleTool(GeoMapTool.suitability),
                  ),
                  _ToolButton(
                    icon: PhosphorIconsRegular.polygon,
                    label: 'Area',
                    showLabel: wide,
                    active: widget.activeTool == GeoMapTool.areaMeasurement,
                    onPressed: () =>
                        widget.onToggleTool(GeoMapTool.areaMeasurement),
                  ),
                  const SizedBox(width: 8),
                  _ToolButton(
                    icon: PhosphorIconsRegular.minus,
                    label: 'Out',
                    showLabel: wide,
                    enabled: widget.zoom > minMapZoom,
                    onPressed: widget.onZoomOut,
                  ),
                  _ToolButton(
                    icon: PhosphorIconsRegular.plus,
                    label: 'In',
                    showLabel: wide,
                    enabled: widget.zoom < maxMapZoom,
                    onPressed: widget.onZoomIn,
                  ),
                  _ToolButton(
                    icon: PhosphorIconsRegular.arrowCounterClockwise,
                    label: 'Reset',
                    showLabel: wide,
                    onPressed: widget.onResetCamera,
                  ),
                ],
              ),
            ),
            if (widget.results.isNotEmpty) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: MapChrome.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MapChrome.border),
        boxShadow: MapChrome.cardShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 18,
            color: MapChrome.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onQueryChanged,
              style: const TextStyle(color: MapChrome.content, fontSize: 14),
              cursorColor: MapChrome.accent,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                hintText: widget.villagesLoaded
                    ? 'Search a village'
                    : 'Loading villages…',
                hintStyle: const TextStyle(
                  color: MapChrome.muted,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(
                PhosphorIconsRegular.x,
                size: 18,
                color: MapChrome.muted,
              ),
              onPressed: () {
                _controller.clear();
                widget.onQueryChanged('');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: MapChrome.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MapChrome.border),
        boxShadow: MapChrome.cardShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: widget.results.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: MapChrome.border),
        itemBuilder: (context, index) {
          final village = widget.results[index];
          return Material(
            type: MaterialType.transparency,
            child: ListTile(
              dense: true,
              leading: const Icon(
                PhosphorIconsRegular.mapPin,
                size: 18,
                color: MapChrome.villages,
              ),
              title: Text(
                village.name,
                style: const TextStyle(color: MapChrome.content, fontSize: 13),
              ),
              subtitle: village.district.isEmpty
                  ? null
                  : Text(
                      village.district,
                      style: const TextStyle(
                        color: MapChrome.muted,
                        fontSize: 11,
                      ),
                    ),
              onTap: () {
                FocusScope.of(context).unfocus();
                widget.onVillageSelected(village);
              },
            ),
          );
        },
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.showName});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: MapChrome.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MapChrome.border),
        boxShadow: MapChrome.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            PhosphorIconsFill.leaf,
            size: 24,
            color: MapChrome.accentYellow,
          ),
          if (showName) ...[
            const SizedBox(width: 8),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital Agriculture',
                  style: TextStyle(
                    color: MapChrome.content,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Mission',
                  style: TextStyle(
                    color: MapChrome.accentYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.onPressed,
    this.active = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool showLabel;
  final VoidCallback onPressed;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? MapChrome.muted.withValues(alpha: 0.4)
        : active
        ? MapChrome.accent
        : MapChrome.content;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: active ? MapChrome.tile : MapChrome.background,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onPressed : null,
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: showLabel ? 14 : 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: MapChrome.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 19, color: color),
                if (showLabel) ...[
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: MapChrome.background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MapChrome.border),
              boxShadow: MapChrome.cardShadow,
            ),
            child: Icon(icon, size: 20, color: MapChrome.content),
          ),
        ),
      ),
    );
  }
}
