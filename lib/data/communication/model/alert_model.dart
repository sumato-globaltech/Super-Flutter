import 'package:super_flutter/data/communication/model/notice_model.dart';

/// AlertModel as returned by the API.
class AlertModel {
  String? id;
  String? title;
  String? description;
  CategoryModel? category;
  DistrictModel? district;
  bool? statewide;
  SeverityModel? severity;
  String? startsOn;
  String? endsOn;

  AlertModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.district,
    this.statewide,
    this.severity,
    this.startsOn,
    this.endsOn,
  });

  AlertModel.fromJson(Map<String, dynamic> json) {
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
  }

  // sf:custom:begin AlertModel
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
    return data;
  }
}

class DistrictModel {
  String? id;
  String? name;

  DistrictModel({this.id, this.name});

  DistrictModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin DistrictModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SeverityModel {
  String? value;
  String? label;

  SeverityModel({this.value, this.label});

  SeverityModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin SeverityModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['label'] = label;
    return data;
  }
}
