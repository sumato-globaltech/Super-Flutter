/// VistaarLanguageModel as returned by the API.
class VistaarLanguageModel {
  String? value;
  String? label;

  VistaarLanguageModel({this.value, this.label});

  VistaarLanguageModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin VistaarLanguageModel
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
