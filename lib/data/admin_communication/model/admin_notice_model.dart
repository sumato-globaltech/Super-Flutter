import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';

/// AdminNoticeModel as returned by the API.
class AdminNoticeModel {
  String? id;
  String? title;
  CategoryModel? category;
  PriorityModel? priority;
  DateTime? publishedAt;
  DateTime? expiresAt;
  String? body;
  StatusModel? status;
  DateTime? createdAt;

  AdminNoticeModel({
    this.id,
    this.title,
    this.category,
    this.priority,
    this.publishedAt,
    this.expiresAt,
    this.body,
    this.status,
    this.createdAt,
  });

  AdminNoticeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    priority = json['priority'] != null
        ? PriorityModel.fromJson(json['priority'])
        : null;
    publishedAt = json['published_at'] != null
        ? DateTime.tryParse(json['published_at'].toString())
        : null;
    expiresAt = json['expires_at'] != null
        ? DateTime.tryParse(json['expires_at'].toString())
        : null;
    body = json['body'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
  }

  // sf:custom:begin AdminNoticeModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (priority != null) {
      data['priority'] = priority!.toJson();
    }
    data['published_at'] = publishedAt?.toIso8601String();
    data['expires_at'] = expiresAt?.toIso8601String();
    data['body'] = body;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}
