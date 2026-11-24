import 'package:super_flutter/data/communication/model/notice_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_item_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';

/// TicketModel as returned by the API.
class TicketModel {
  String? id;
  String? number;
  String? subject;
  StatusModel? status;
  CategoryModel? category;
  CropModel? crop;
  String? question;
  String? outcome;
  DateTime? createdAt;
  DateTime? resolvedAt;
  List<PhotoModel>? photos;
  List<ReplyModel>? replies;

  TicketModel({
    this.id,
    this.number,
    this.subject,
    this.status,
    this.category,
    this.crop,
    this.question,
    this.outcome,
    this.createdAt,
    this.resolvedAt,
    this.photos,
    this.replies,
  });

  TicketModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    subject = json['subject'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    crop = json['crop'] != null ? CropModel.fromJson(json['crop']) : null;
    question = json['question'];
    outcome = json['outcome'];
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
    resolvedAt = json['resolved_at'] != null
        ? DateTime.tryParse(json['resolved_at'].toString())
        : null;
    if (json['photos'] != null) {
      photos = <PhotoModel>[];
      json['photos'].forEach((v) {
        photos!.add(PhotoModel.fromJson(v));
      });
    }
    if (json['replies'] != null) {
      replies = <ReplyModel>[];
      json['replies'].forEach((v) {
        replies!.add(ReplyModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin TicketModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['subject'] = subject;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (crop != null) {
      data['crop'] = crop!.toJson();
    }
    data['question'] = question;
    data['outcome'] = outcome;
    data['created_at'] = createdAt?.toIso8601String();
    data['resolved_at'] = resolvedAt?.toIso8601String();
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PhotoModel {
  String? id;
  String? url;
  String? mimeType;
  int? size;
  DateTime? createdAt;

  PhotoModel({this.id, this.url, this.mimeType, this.size, this.createdAt});

  PhotoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    mimeType = json['mime_type'];
    size = json['size'];
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
  }

  // sf:custom:begin PhotoModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['mime_type'] = mimeType;
    data['size'] = size;
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}

class ReplyModel {
  String? id;
  String? body;
  DateTime? createdAt;

  ReplyModel({this.id, this.body, this.createdAt});

  ReplyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    body = json['body'];
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
  }

  // sf:custom:begin ReplyModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['body'] = body;
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}
