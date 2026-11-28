import 'package:equatable/equatable.dart';

/// An agriculture office returned by the GIS office-locations API.
class OfficeLocationModel extends Equatable {
  const OfficeLocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    this.contactPhone,
    required this.address,
    required this.district,
    required this.state,
  });

  factory OfficeLocationModel.fromJson(Map<String, dynamic> json) {
    final location =
        (json['geo_location'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final contact =
        (json['contact_person'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final district =
        (json['district'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final state =
        (district['state'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final phone = '${contact['phone_number'] ?? ''}'.trim();

    return OfficeLocationModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      type: '${json['office_type'] ?? ''}',
      latitude: double.tryParse('${location['latitude'] ?? ''}') ?? 0,
      longitude: double.tryParse('${location['longitude'] ?? ''}') ?? 0,
      contactName: '${contact['name'] ?? ''}',
      contactPhone: phone.isEmpty ? null : phone,
      address: '${json['address'] ?? ''}',
      district: '${district['name'] ?? ''}',
      state: '${state['name'] ?? ''}',
    );
  }

  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String contactName;
  final String? contactPhone;
  final String address;
  final String district;
  final String state;

  @override
  List<Object?> get props => [id, name, latitude, longitude];
}
