import 'package:super_flutter/data/shipments/model/shipment_item_model.dart';

/// ShipmentOptionsModel as returned by the API.
class ShipmentOptionsModel {
  List<VendorModel>? vendors;
  List<PickupDistrictModel>? pickupDistricts;
  List<CropModel>? crops;
  List<UnitModel>? units;
  DefaultsModel? defaults;
  LimitsModel? limits;

  ShipmentOptionsModel({
    this.vendors,
    this.pickupDistricts,
    this.crops,
    this.units,
    this.defaults,
    this.limits,
  });

  ShipmentOptionsModel.fromJson(Map<String, dynamic> json) {
    if (json['vendors'] != null) {
      vendors = <VendorModel>[];
      json['vendors'].forEach((v) {
        vendors!.add(VendorModel.fromJson(v));
      });
    }
    if (json['pickup_districts'] != null) {
      pickupDistricts = <PickupDistrictModel>[];
      json['pickup_districts'].forEach((v) {
        pickupDistricts!.add(PickupDistrictModel.fromJson(v));
      });
    }
    if (json['crops'] != null) {
      crops = <CropModel>[];
      json['crops'].forEach((v) {
        crops!.add(CropModel.fromJson(v));
      });
    }
    if (json['units'] != null) {
      units = <UnitModel>[];
      json['units'].forEach((v) {
        units!.add(UnitModel.fromJson(v));
      });
    }
    defaults = json['defaults'] != null
        ? DefaultsModel.fromJson(json['defaults'])
        : null;
    limits = json['limits'] != null
        ? LimitsModel.fromJson(json['limits'])
        : null;
  }

  // sf:custom:begin ShipmentOptionsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (vendors != null) {
      data['vendors'] = vendors!.map((v) => v.toJson()).toList();
    }
    if (pickupDistricts != null) {
      data['pickup_districts'] = pickupDistricts!
          .map((v) => v.toJson())
          .toList();
    }
    if (crops != null) {
      data['crops'] = crops!.map((v) => v.toJson()).toList();
    }
    if (units != null) {
      data['units'] = units!.map((v) => v.toJson()).toList();
    }
    if (defaults != null) {
      data['defaults'] = defaults!.toJson();
    }
    if (limits != null) {
      data['limits'] = limits!.toJson();
    }
    return data;
  }
}

class VendorModel {
  String? id;
  String? code;
  String? name;
  List<String>? districts;

  VendorModel({this.id, this.code, this.name, this.districts});

  VendorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    districts = json['districts']?.cast<String>();
  }

  // sf:custom:begin VendorModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['districts'] = districts;
    return data;
  }
}

class PickupDistrictModel {
  String? id;
  String? name;

  PickupDistrictModel({this.id, this.name});

  PickupDistrictModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin PickupDistrictModel
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

class DefaultsModel {
  String? pickupAddress;
  String? preferredPickupOn;
  String? pickupDistrictId;

  DefaultsModel({
    this.pickupAddress,
    this.preferredPickupOn,
    this.pickupDistrictId,
  });

  DefaultsModel.fromJson(Map<String, dynamic> json) {
    pickupAddress = json['pickup_address'];
    preferredPickupOn = json['preferred_pickup_on'];
    pickupDistrictId = json['pickup_district_id'];
  }

  // sf:custom:begin DefaultsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pickup_address'] = pickupAddress;
    data['preferred_pickup_on'] = preferredPickupOn;
    data['pickup_district_id'] = pickupDistrictId;
    return data;
  }
}

class LimitsModel {
  int? maxItems;
  int? maxQuantity;
  int? reasonMax;

  LimitsModel({this.maxItems, this.maxQuantity, this.reasonMax});

  LimitsModel.fromJson(Map<String, dynamic> json) {
    maxItems = json['max_items'];
    maxQuantity = json['max_quantity'];
    reasonMax = json['reason_max'];
  }

  // sf:custom:begin LimitsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['max_items'] = maxItems;
    data['max_quantity'] = maxQuantity;
    data['reason_max'] = reasonMax;
    return data;
  }
}
