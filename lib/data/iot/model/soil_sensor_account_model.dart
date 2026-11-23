import 'package:equatable/equatable.dart';

class SoilSensorAccountModel extends Equatable {
  final String? provider;
  final String? username;
  final bool? isActive;
  final String? linkedAt;
  final String? lastSyncedAt;

  const SoilSensorAccountModel({
    this.provider,
    this.username,
    this.isActive,
    this.linkedAt,
    this.lastSyncedAt,
  });

  factory SoilSensorAccountModel.fromJson(Map<String, dynamic> json) {
    return SoilSensorAccountModel(
      provider: json['provider']?.toString(),
      username: json['username']?.toString(),
      isActive: json['is_active'] as bool?,
      linkedAt: json['linked_at']?.toString(),
      lastSyncedAt: json['last_synced_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (provider != null) 'provider': provider,
        if (username != null) 'username': username,
        if (isActive != null) 'is_active': isActive,
        if (linkedAt != null) 'linked_at': linkedAt,
        if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      };

  @override
  List<Object?> get props => [
        provider,
        username,
        isActive,
        linkedAt,
        lastSyncedAt,
      ];
}
