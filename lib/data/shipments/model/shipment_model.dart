import 'package:super_flutter/data/shipments/model/shipment_item_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_party_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_pickup_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_vehicle_model.dart';

/// ShipmentModel as returned by the API.
class ShipmentModel {
  String? id;
  String? number;
  StatusModel? status;
  List<String>? actions;
  ShipmentPartyModel? farmer;
  ShipmentPartyModel? vendor;
  ShipmentPickupModel? pickup;
  ShipmentVehicleModel? vehicle;
  DriverModel? driver;
  String? rejectReason;
  DateTime? requestedAt;
  DateTime? acceptedAt;
  DateTime? rejectedAt;
  DateTime? pickedUpAt;
  DateTime? reachedAt;
  DateTime? receivedAt;
  List<ItemModel>? items;
  String? notes;
  String? cancelReason;
  DateTime? cancelledAt;

  ShipmentModel({
    this.id,
    this.number,
    this.status,
    this.actions,
    this.farmer,
    this.vendor,
    this.pickup,
    this.vehicle,
    this.driver,
    this.rejectReason,
    this.requestedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.pickedUpAt,
    this.reachedAt,
    this.receivedAt,
    this.items,
    this.notes,
    this.cancelReason,
    this.cancelledAt,
  });

  ShipmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    status = json['status'] != null
        ? StatusModel.fromJson(json['status'])
        : null;
    actions = json['actions']?.cast<String>();
    farmer = json['farmer'] != null
        ? ShipmentPartyModel.fromJson(json['farmer'])
        : null;
    vendor = json['vendor'] != null
        ? ShipmentPartyModel.fromJson(json['vendor'])
        : null;
    pickup = json['pickup'] != null
        ? ShipmentPickupModel.fromJson(json['pickup'])
        : null;
    vehicle = json['vehicle'] != null
        ? ShipmentVehicleModel.fromJson(json['vehicle'])
        : null;
    driver = json['driver'] != null
        ? DriverModel.fromJson(json['driver'])
        : null;
    rejectReason = json['reject_reason'];
    requestedAt = json['requested_at'] != null
        ? DateTime.tryParse(json['requested_at'].toString())
        : null;
    acceptedAt = json['accepted_at'] != null
        ? DateTime.tryParse(json['accepted_at'].toString())
        : null;
    rejectedAt = json['rejected_at'] != null
        ? DateTime.tryParse(json['rejected_at'].toString())
        : null;
    pickedUpAt = json['picked_up_at'] != null
        ? DateTime.tryParse(json['picked_up_at'].toString())
        : null;
    reachedAt = json['reached_at'] != null
        ? DateTime.tryParse(json['reached_at'].toString())
        : null;
    receivedAt = json['received_at'] != null
        ? DateTime.tryParse(json['received_at'].toString())
        : null;
    if (json['items'] != null) {
      items = <ItemModel>[];
      json['items'].forEach((v) {
        items!.add(ItemModel.fromJson(v));
      });
    }
    notes = json['notes'];
    cancelReason = json['cancel_reason'];
    cancelledAt = json['cancelled_at'] != null
        ? DateTime.tryParse(json['cancelled_at'].toString())
        : null;
  }

  // sf:custom:begin ShipmentModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['actions'] = actions;
    if (farmer != null) {
      data['farmer'] = farmer!.toJson();
    }
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    if (pickup != null) {
      data['pickup'] = pickup!.toJson();
    }
    if (vehicle != null) {
      data['vehicle'] = vehicle!.toJson();
    }
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    data['reject_reason'] = rejectReason;
    data['requested_at'] = requestedAt?.toIso8601String();
    data['accepted_at'] = acceptedAt?.toIso8601String();
    data['rejected_at'] = rejectedAt?.toIso8601String();
    data['picked_up_at'] = pickedUpAt?.toIso8601String();
    data['reached_at'] = reachedAt?.toIso8601String();
    data['received_at'] = receivedAt?.toIso8601String();
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['notes'] = notes;
    data['cancel_reason'] = cancelReason;
    data['cancelled_at'] = cancelledAt?.toIso8601String();
    return data;
  }
}

class StatusModel {
  String? value;
  String? label;

  StatusModel({this.value, this.label});

  StatusModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin StatusModel
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

class DriverModel {
  String? id;
  String? code;
  String? name;
  String? phone;

  DriverModel({this.id, this.code, this.name, this.phone});

  DriverModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    phone = json['phone'];
  }

  // sf:custom:begin DriverModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['phone'] = phone;
    return data;
  }
}

class ItemModel {
  String? id;
  CropModel? crop;
  UnitModel? unit;
  double? quantitySold;
  double? quantityPicked;
  double? quantityReceived;
  double? pickedDifference;
  double? receivedDifference;
  List<dynamic>? reweighs;

  ItemModel({
    this.id,
    this.crop,
    this.unit,
    this.quantitySold,
    this.quantityPicked,
    this.quantityReceived,
    this.pickedDifference,
    this.receivedDifference,
    this.reweighs,
  });

  ItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    crop = json['crop'] != null ? CropModel.fromJson(json['crop']) : null;
    unit = json['unit'] != null ? UnitModel.fromJson(json['unit']) : null;
    quantitySold = (json['quantity_sold'] as num?)?.toDouble();
    quantityPicked = (json['quantity_picked'] as num?)?.toDouble();
    quantityReceived = (json['quantity_received'] as num?)?.toDouble();
    pickedDifference = (json['picked_difference'] as num?)?.toDouble();
    receivedDifference = (json['received_difference'] as num?)?.toDouble();
    reweighs = json['reweighs']?.cast<dynamic>();
  }

  // sf:custom:begin ItemModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (crop != null) {
      data['crop'] = crop!.toJson();
    }
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    data['quantity_sold'] = quantitySold;
    data['quantity_picked'] = quantityPicked;
    data['quantity_received'] = quantityReceived;
    data['picked_difference'] = pickedDifference;
    data['received_difference'] = receivedDifference;
    data['reweighs'] = reweighs;
    return data;
  }
}
