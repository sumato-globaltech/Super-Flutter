import 'package:equatable/equatable.dart';
import 'crop_advisory_model.dart';
import 'crop_model.dart';

class CropCalendarModel extends Equatable {
  final CropModel? crop;
  final DistrictModel? district;
  final MonthModel? month;
  final WindowsModel? windows;
  final CropCalendarScheduleModel? calendar;

  const CropCalendarModel({
    this.crop,
    this.district,
    this.month,
    this.windows,
    this.calendar,
  });

  factory CropCalendarModel.fromJson(Map<String, dynamic> json) {
    return CropCalendarModel(
      crop: json['crop'] is Map
          ? CropModel.fromJson(Map<String, dynamic>.from(json['crop'] as Map))
          : null,
      district: json['district'] is Map
          ? DistrictModel.fromJson(
              Map<String, dynamic>.from(json['district'] as Map),
            )
          : null,
      month: json['month'] is Map
          ? MonthModel.fromJson(Map<String, dynamic>.from(json['month'] as Map))
          : null,
      windows: json['windows'] is Map
          ? WindowsModel.fromJson(
              Map<String, dynamic>.from(json['windows'] as Map),
            )
          : null,
      calendar: json['calendar'] is Map
          ? CropCalendarScheduleModel.fromJson(
              Map<String, dynamic>.from(json['calendar'] as Map),
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [crop, district, month, windows, calendar];
}

class CropCalendarScheduleModel extends Equatable {
  final List<dynamic> current;
  final List<dynamic> upcoming;
  final List<dynamic> all;

  const CropCalendarScheduleModel({
    this.current = const [],
    this.upcoming = const [],
    this.all = const [],
  });

  factory CropCalendarScheduleModel.fromJson(Map<String, dynamic> json) {
    return CropCalendarScheduleModel(
      current: json['current'] is List ? json['current'] as List : const [],
      upcoming: json['upcoming'] is List ? json['upcoming'] as List : const [],
      all: json['all'] is List ? json['all'] as List : const [],
    );
  }

  @override
  List<Object?> get props => [current, upcoming, all];
}
