import 'package:super_flutter/data/communication/model/alert_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';

/// AdminAlertModel as returned by the API.
class AdminAlertModel {
  String? id;
  String? title;
  String? description;
  CategoryModel? category;
  DistrictModel? district;
  bool? statewide;
  SeverityModel? severity;
  String? startsOn;
  String? endsOn;
  StatusModel? status;
  DateTime? createdAt;

  AdminAlertModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.district,
    this.statewide,
    this.severity,
    this.startsOn,
    this.endsOn,
    this.status,
    this.createdAt,
  });

  AdminAlertModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    district = json['district'] != null
        ? DistrictModel.fromJson(json['district'])
        : null;
    statewide = json['statewide'];
    severity = json['severity'] != null
        ? SeverityModel.fromJson(json['severity'])
        : null;
    startsOn = json['starts_on'];
    endsOn = json['ends_on'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
  }

  // sf:custom:begin AdminAlertModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (district != null) {
      data['district'] = district!.toJson();
    }
    data['statewide'] = statewide;
    if (severity != null) {
      data['severity'] = severity!.toJson();
    }
    data['starts_on'] = startsOn;
    data['ends_on'] = endsOn;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}
