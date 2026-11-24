import 'package:super_flutter/data/admin_communication/model/district_model.dart';
import 'package:super_flutter/data/communication/model/notice_model.dart';

/// FacilityModel as returned by the API.
class FacilityModel {
  String? id;
  String? name;
  CategoryModel? category;
  DistrictModel? district;
  String? address;
  double? latitude;
  double? longitude;
  double? capacityTpd;
  double? storageAreaSqm;
  List<String>? products;
  bool? isOperational;

  FacilityModel({
    this.id,
    this.name,
    this.category,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.capacityTpd,
    this.storageAreaSqm,
    this.products,
    this.isOperational,
  });

  FacilityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    district = json['district'] != null
        ? DistrictModel.fromJson(json['district'])
        : null;
    address = json['address'];
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    capacityTpd = (json['capacity_tpd'] as num?)?.toDouble();
    storageAreaSqm = (json['storage_area_sqm'] as num?)?.toDouble();
    products = json['products']?.cast<String>();
    isOperational = json['is_operational'];
  }

  // sf:custom:begin FacilityModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (district != null) {
      data['district'] = district!.toJson();
    }
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['capacity_tpd'] = capacityTpd;
    data['storage_area_sqm'] = storageAreaSqm;
    data['products'] = products;
    data['is_operational'] = isOperational;
    return data;
  }
}
