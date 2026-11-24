import 'package:super_flutter/data/communication/model/alert_model.dart';

/// ShipmentPickupModel as returned by the API.
class ShipmentPickupModel {
  DistrictModel? district;
  String? address;
  String? preferredOn;
  bool? late;

  ShipmentPickupModel({
    this.district,
    this.address,
    this.preferredOn,
    this.late,
  });

  ShipmentPickupModel.fromJson(Map<String, dynamic> json) {
    district = json['district'] != null
        ? DistrictModel.fromJson(json['district'])
        : null;
    address = json['address'];
    preferredOn = json['preferred_on'];
    late = json['late'];
  }

  // sf:custom:begin ShipmentPickupModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (district != null) {
      data['district'] = district!.toJson();
    }
    data['address'] = address;
    data['preferred_on'] = preferredOn;
    data['late'] = late;
    return data;
  }
}
