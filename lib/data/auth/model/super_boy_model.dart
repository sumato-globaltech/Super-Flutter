/// SuperBoyModel as returned by the API.
class SuperBoyModel {
  int? sff;

  SuperBoyModel({this.sff});

  SuperBoyModel.fromJson(Map<String, dynamic> json) {
    sff = json['sff'];
  }

  // sf:custom:begin SuperBoyModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sff'] = sff;
    return data;
  }
}
