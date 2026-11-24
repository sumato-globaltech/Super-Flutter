/// LandOwnershipModel as returned by the API.
class LandOwnershipModel {
  String? id;
  String? name;

  LandOwnershipModel({this.id, this.name});

  LandOwnershipModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin LandOwnershipModel
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
