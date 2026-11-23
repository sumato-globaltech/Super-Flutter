/// BlockModel as returned by the API.
class BlockModel {
  String? id;
  String? name;
  String? code;
  String? districtId;

  BlockModel({this.id, this.name, this.code, this.districtId});

  BlockModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    districtId = json['district_id'];
  }

  // sf:custom:begin BlockModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['district_id'] = districtId;
    return data;
  }
}
