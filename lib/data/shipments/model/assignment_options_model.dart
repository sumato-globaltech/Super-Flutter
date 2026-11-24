import 'package:super_flutter/data/shipments/model/shipment_party_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_vehicle_model.dart';

/// AssignmentOptionsModel as returned by the API.
class AssignmentOptionsModel {
  List<VehicleModel>? vehicles;
  List<ShipmentPartyModel>? drivers;

  AssignmentOptionsModel({this.vehicles, this.drivers});

  AssignmentOptionsModel.fromJson(Map<String, dynamic> json) {
    if (json['vehicles'] != null) {
      vehicles = <VehicleModel>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(VehicleModel.fromJson(v));
      });
    }
    if (json['drivers'] != null) {
      drivers = <ShipmentPartyModel>[];
      json['drivers'].forEach((v) {
        drivers!.add(ShipmentPartyModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin AssignmentOptionsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    if (drivers != null) {
      data['drivers'] = drivers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleModel {
  String? id;
  String? registrationNumber;
  TypeModel? type;
  bool? onTrip;

  VehicleModel({this.id, this.registrationNumber, this.type, this.onTrip});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    registrationNumber = json['registration_number'];
    type = json['type'] != null ? TypeModel.fromJson(json['type']) : null;
    onTrip = json['on_trip'];
  }

  // sf:custom:begin VehicleModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['registration_number'] = registrationNumber;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['on_trip'] = onTrip;
    return data;
  }
}
