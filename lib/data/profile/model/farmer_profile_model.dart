import 'package:super_flutter/data/admin_communication/model/district_model.dart';

/// FarmerProfileModel as returned by the API.
class FarmerProfileModel {
  String? id;
  String? code;
  String? name;
  String? phone;
  String? email;
  GenderModel? gender;
  String? dateOfBirth;
  DistrictModel? district;
  BlockModel? block;
  List<DistrictModel>? districts;
  List<BlockModel2Model>? blocks;
  String? village;
  String? address;
  double? landAreaHa;
  LandOwnershipModel? landOwnership;
  bool? isVerified;
  DateTime? verifiedAt;

  FarmerProfileModel({
    this.id,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.district,
    this.block,
    this.districts,
    this.blocks,
    this.village,
    this.address,
    this.landAreaHa,
    this.landOwnership,
    this.isVerified,
    this.verifiedAt,
  });

  FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    gender = json['gender'] != null
        ? GenderModel.fromJson(json['gender'])
        : null;
    dateOfBirth = json['date_of_birth'];
    district = json['district'] != null
        ? DistrictModel.fromJson(json['district'])
        : null;
    block = json['block'] != null ? BlockModel.fromJson(json['block']) : null;
    if (json['districts'] != null) {
      districts = <DistrictModel>[];
      json['districts'].forEach((v) {
        districts!.add(DistrictModel.fromJson(v));
      });
    }
    if (json['blocks'] != null) {
      blocks = <BlockModel2Model>[];
      json['blocks'].forEach((v) {
        blocks!.add(BlockModel2Model.fromJson(v));
      });
    }
    village = json['village'];
    address = json['address'];
    landAreaHa = (json['land_area_ha'] as num?)?.toDouble();
    landOwnership = json['land_ownership'] != null
        ? LandOwnershipModel.fromJson(json['land_ownership'])
        : null;
    isVerified = json['is_verified'];
    verifiedAt = json['verified_at'] != null
        ? DateTime.tryParse(json['verified_at'].toString())
        : null;
  }

  // sf:custom:begin FarmerProfileModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    if (gender != null) {
      data['gender'] = gender!.toJson();
    }
    data['date_of_birth'] = dateOfBirth;
    if (district != null) {
      data['district'] = district!.toJson();
    }
    if (block != null) {
      data['block'] = block!.toJson();
    }
    if (districts != null) {
      data['districts'] = districts!.map((v) => v.toJson()).toList();
    }
    if (blocks != null) {
      data['blocks'] = blocks!.map((v) => v.toJson()).toList();
    }
    data['village'] = village;
    data['address'] = address;
    data['land_area_ha'] = landAreaHa;
    if (landOwnership != null) {
      data['land_ownership'] = landOwnership!.toJson();
    }
    data['is_verified'] = isVerified;
    data['verified_at'] = verifiedAt?.toIso8601String();
    return data;
  }
}

class GenderModel {
  String? value;
  String? label;

  GenderModel({this.value, this.label});

  GenderModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin GenderModel
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

class BlockModel {
  String? id;
  String? name;

  BlockModel({this.id, this.name});

  BlockModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin BlockModel
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

class BlockModel2Model {
  String? id;
  String? name;

  BlockModel2Model({this.id, this.name});

  BlockModel2Model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin BlockModel2Model
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

class LandOwnershipModel {
  String? value;
  String? label;

  LandOwnershipModel({this.value, this.label});

  LandOwnershipModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin LandOwnershipModel
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
