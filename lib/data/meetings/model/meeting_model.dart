import 'package:super_flutter/data/shipments/model/shipment_model.dart';

/// MeetingModel as returned by the API.
class MeetingModel {
  String? id;
  String? agenda;
  DateTime? startsAt;
  DateTime? rescheduledFrom;
  String? link;
  StatusModel? status;

  MeetingModel({
    this.id,
    this.agenda,
    this.startsAt,
    this.rescheduledFrom,
    this.link,
    this.status,
  });

  MeetingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    agenda = json['agenda'];
    startsAt = json['starts_at'] != null
        ? DateTime.tryParse(json['starts_at'].toString())
        : null;
    rescheduledFrom = json['rescheduled_from'] != null
        ? DateTime.tryParse(json['rescheduled_from'].toString())
        : null;
    link = json['link'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
  }

  // sf:custom:begin MeetingModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['agenda'] = agenda;
    data['starts_at'] = startsAt?.toIso8601String();
    data['rescheduled_from'] = rescheduledFrom?.toIso8601String();
    data['link'] = link;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}
