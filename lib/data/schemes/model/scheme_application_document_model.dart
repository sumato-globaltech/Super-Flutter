import 'package:super_flutter/data/shipments/model/shipment_model.dart';

/// SchemeApplicationDocumentModel as returned by the API.
class SchemeApplicationDocumentModel {
  String? id;
  String? name;
  StatusModel? status;
  String? remarks;
  bool? uploaded;
  String? url;

  SchemeApplicationDocumentModel({
    this.id,
    this.name,
    this.status,
    this.remarks,
    this.uploaded,
    this.url,
  });

  SchemeApplicationDocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    remarks = json['remarks'];
    uploaded = json['uploaded'];
    url = json['url'];
  }

  // sf:custom:begin SchemeApplicationDocumentModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['remarks'] = remarks;
    data['uploaded'] = uploaded;
    data['url'] = url;
    return data;
  }
}
