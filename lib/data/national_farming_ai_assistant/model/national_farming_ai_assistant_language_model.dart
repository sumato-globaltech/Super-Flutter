/// NationalFarmingAiAssistantLanguageModel as returned by the API.
class NationalFarmingAiAssistantLanguageModel {
  String? value;
  String? label;

  NationalFarmingAiAssistantLanguageModel({this.value, this.label});

  NationalFarmingAiAssistantLanguageModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin NationalFarmingAiAssistantLanguageModel
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
