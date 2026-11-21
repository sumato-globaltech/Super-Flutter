/// DistrictModel as returned by the API.
class DistrictModel {
  String? id;
  String? name;
  String? code;
  String? stateId;
  StateModel? state;

  DistrictModel({this.id, this.name, this.code, this.stateId, this.state});

  DistrictModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    stateId = json['state_id'];
    state = json['state'] != null ? StateModel.fromJson(json['state']) : null;
  }

  // sf:custom:begin DistrictModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    data['state_id'] = stateId;
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}

class StateModel {
  String? id;
  String? name;
  String? code;

  StateModel({this.id, this.name, this.code});

  StateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
  }

  // sf:custom:begin StateModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}
