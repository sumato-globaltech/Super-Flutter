import 'package:material_ui/material_ui.dart';

/// Floating map chrome palette. It stays dark over satellite imagery in both
/// app themes, matching the NL map reference.
abstract final class MapChrome {
  static const background = Color(0xFF1E2939);
  static const tile = Color(0xFF273449);
  static const content = Color(0xFFF1F5F9);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0x33FFFFFF);
  static const accent = Color(0xFF38BDF8);
  static const accentYellow = Color(0xFFFACC15);
  static const closeButton = Color(0xFF454545);
  static const closeIcon = Colors.white;
  static const villages = Color(0xFFFB923C);
  static const districtOutline = Color(0xFF800080);
  static const districtSelected = Color(0x60800080);

  static final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(color: border),
  );

  static const cardShadow = [
    BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
  ];
}
