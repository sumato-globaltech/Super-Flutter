import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/features/map/presentation/map/layers/asset_layer_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled catalog parses, substitutes variables, stays valid', () async {
    final defs = await AssetLayerCatalog().load();

    expect(defs.map((d) => d.id), containsAll([
      'satellite_layer',
      'nh_layer',
      'villages_layer',
    ]));
    // No unsubstituted placeholders survive in data URLs.
    for (final def in defs) {
      final source = def.source.toString();
      expect(source.contains('{tileHost}'), false, reason: def.id);
    }
    // One eager base group; overlays lazy.
    expect(defs.where((d) => d.eager).map((d) => d.id), ['satellite_layer']);
    expect(
      defs.where((d) => !d.eager).map((d) => d.group).toSet(),
      {'overlays'},
    );
    // Villages load hidden; the toggle reveals them without refetch.
    final villages = defs.firstWhere((d) => d.id == 'villages_layer');
    expect(villages.visible, false);
  });
}
