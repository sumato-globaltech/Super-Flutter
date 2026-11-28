import 'package:equatable/equatable.dart';

/// How suitable one crop is at a map point.
class CropSuitabilityModel extends Equatable {
  const CropSuitabilityModel({
    required this.key,
    required this.label,
    required this.percent,
  });

  factory CropSuitabilityModel.fromJson(Map<String, dynamic> json) {
    final percent = _number(json['percent']) ?? 0;
    return CropSuitabilityModel(
      key: '${json['key'] ?? ''}',
      label: '${json['label'] ?? ''}'.trim().isEmpty
          ? '${json['key'] ?? ''}'
          : '${json['label']}',
      percent: percent.clamp(0, 100).toDouble(),
    );
  }

  final String key;
  final String label;
  final double percent;

  @override
  List<Object?> get props => [key, label, percent];
}

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}
