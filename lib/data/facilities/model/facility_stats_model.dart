/// FacilityStatsModel as returned by the API.
class FacilityStatsModel {
  int? total;
  int? operational;
  List<ByCategoryModel>? byCategory;
  List<ByCategoryModel>? byDistrict;

  FacilityStatsModel({
    this.total,
    this.operational,
    this.byCategory,
    this.byDistrict,
  });

  FacilityStatsModel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    operational = json['operational'];
    if (json['by_category'] != null) {
      byCategory = <ByCategoryModel>[];
      json['by_category'].forEach((v) {
        byCategory!.add(ByCategoryModel.fromJson(v));
      });
    }
    if (json['by_district'] != null) {
      byDistrict = <ByCategoryModel>[];
      json['by_district'].forEach((v) {
        byDistrict!.add(ByCategoryModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin FacilityStatsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['operational'] = operational;
    if (byCategory != null) {
      data['by_category'] = byCategory!.map((v) => v.toJson()).toList();
    }
    if (byDistrict != null) {
      data['by_district'] = byDistrict!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ByCategoryModel {
  String? id;
  String? name;
  int? total;
  int? operational;
  double? capacityTpd;
  double? storageAreaSqm;

  ByCategoryModel({
    this.id,
    this.name,
    this.total,
    this.operational,
    this.capacityTpd,
    this.storageAreaSqm,
  });

  ByCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    total = json['total'];
    operational = json['operational'];
    capacityTpd = (json['capacity_tpd'] as num?)?.toDouble();
    storageAreaSqm = (json['storage_area_sqm'] as num?)?.toDouble();
  }

  // sf:custom:begin ByCategoryModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['total'] = total;
    data['operational'] = operational;
    data['capacity_tpd'] = capacityTpd;
    data['storage_area_sqm'] = storageAreaSqm;
    return data;
  }
}
