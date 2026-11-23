import 'package:equatable/equatable.dart';

class IntegrationRunModel extends Equatable {
  final String? id;
  final String? status;
  final String? queuedAt;
  final String? startedAt;
  final String? finishedAt;

  const IntegrationRunModel({
    this.id,
    this.status,
    this.queuedAt,
    this.startedAt,
    this.finishedAt,
  });

  factory IntegrationRunModel.fromJson(Map<String, dynamic> json) {
    return IntegrationRunModel(
      id: json['id']?.toString(),
      status: json['status']?.toString(),
      queuedAt: json['queued_at']?.toString(),
      startedAt: json['started_at']?.toString(),
      finishedAt: json['finished_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (status != null) 'status': status,
    if (queuedAt != null) 'queued_at': queuedAt,
    if (startedAt != null) 'started_at': startedAt,
    if (finishedAt != null) 'finished_at': finishedAt,
  };

  @override
  List<Object?> get props => [id, status, queuedAt, startedAt, finishedAt];
}
