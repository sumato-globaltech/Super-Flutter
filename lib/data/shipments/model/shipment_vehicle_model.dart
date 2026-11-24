/// ShipmentVehicleModel as returned by the API.
class ShipmentVehicleModel {
  String? id;
  String? registrationNumber;
  TypeModel? type;

  ShipmentVehicleModel({this.id, this.registrationNumber, this.type});

  ShipmentVehicleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    registrationNumber = json['registration_number'];
    type = json['type'] != null ? TypeModel.fromJson(json['type']) : null;
  }

  // sf:custom:begin ShipmentVehicleModel
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
    return data;
  }
}

class TypeModel {
  String? value;
  String? label;

  TypeModel({this.value, this.label});

  TypeModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin TypeModel
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
