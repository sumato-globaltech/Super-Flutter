import 'package:equatable/equatable.dart';

/// One district and the statistics the details card shows.
class DistrictInfoModel extends Equatable {
  const DistrictInfoModel({
    required this.key,
    required this.name,
    this.areaSqKm,
    this.population,
    this.villageCount,
    this.croplandHa,
    this.barrenHa,
    this.builtUpHa,
    this.forestHa,
  });

  factory DistrictInfoModel.fromProperties(
    String key,
    Map<String, dynamic> properties,
  ) {
    return DistrictInfoModel(
      key: key,
      name: _text(properties['District_N']).ifBlankOr(key),
      areaSqKm: _number(properties['Area_SqKm']),
      population: _number(properties['pop2'])?.toInt(),
      villageCount: _number(properties['N0_vill'])?.toInt(),
      croplandHa: _number(properties['cropland']),
      barrenHa: _number(properties['barren']),
      builtUpHa: _number(properties['builtup']),
      forestHa: _number(properties['forest']),
    );
  }

  final String key;
  final String name;
  final double? areaSqKm;
  final int? population;
  final int? villageCount;
  final double? croplandHa;
  final double? barrenHa;
  final double? builtUpHa;
  final double? forestHa;

  @override
  List<Object?> get props => [key, name, areaSqKm, population, villageCount];
}

String _text(Object? value) => value == null ? '' : '$value';

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

extension on String {
  String ifBlankOr(String fallback) => trim().isEmpty ? fallback : this;
}
