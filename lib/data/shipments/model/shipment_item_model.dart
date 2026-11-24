/// ShipmentItemModel as returned by the API.
class ShipmentItemModel {
  String? id;
  CropModel? crop;
  UnitModel? unit;
  int? quantitySold;
  List<dynamic>? reweighs;

  ShipmentItemModel({
    this.id,
    this.crop,
    this.unit,
    this.quantitySold,
    this.reweighs,
  });

  ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    crop = json['crop'] != null ? CropModel.fromJson(json['crop']) : null;
    unit = json['unit'] != null ? UnitModel.fromJson(json['unit']) : null;
    quantitySold = json['quantity_sold'];
    reweighs = json['reweighs']?.cast<dynamic>();
  }

  // sf:custom:begin ShipmentItemModel
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
    data['reweighs'] = reweighs;
    return data;
  }
}

class CropModel {
  String? id;
  String? name;

  CropModel({this.id, this.name});

  CropModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin CropModel
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

class UnitModel {
  String? id;
  String? name;

  UnitModel({this.id, this.name});

  UnitModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin UnitModel
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
