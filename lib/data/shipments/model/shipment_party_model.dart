/// ShipmentPartyModel as returned by the API.
class ShipmentPartyModel {
  String? id;
  String? code;
  String? name;

  ShipmentPartyModel({this.id, this.code, this.name});

  ShipmentPartyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }

  // sf:custom:begin ShipmentPartyModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
