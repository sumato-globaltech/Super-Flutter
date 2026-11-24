import 'package:super_flutter/data/shipments/model/shipment_party_model.dart';

/// DistrictOptionModel as returned by the API.
class DistrictOptionModel {
  String? id;
  String? name;
  String? code;
  ShipmentPartyModel? state;

  DistrictOptionModel({this.id, this.name, this.code, this.state});

  DistrictOptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    state = json['state'] != null
        ? ShipmentPartyModel.fromJson(json['state'])
        : null;
  }

  // sf:custom:begin DistrictOptionModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}
