/// CallCenterModel as returned by the API.
class CallCenterModel {
  String? district;
  String? number;

  CallCenterModel({this.district, this.number});

  CallCenterModel.fromJson(Map<String, dynamic> json) {
    district = json['district'];
    number = json['number'];
  }

  // sf:custom:begin CallCenterModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['district'] = district;
    data['number'] = number;
    return data;
  }
}
