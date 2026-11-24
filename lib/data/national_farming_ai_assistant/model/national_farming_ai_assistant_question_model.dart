/// NationalFarmingAiAssistantQuestionModel as returned by the API.
class NationalFarmingAiAssistantQuestionModel {
  String? key;
  String? question;
  bool? prefill;

  NationalFarmingAiAssistantQuestionModel({
    this.key,
    this.question,
    this.prefill,
  });

  NationalFarmingAiAssistantQuestionModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    question = json['question'];
    prefill = json['prefill'];
  }

  // sf:custom:begin NationalFarmingAiAssistantQuestionModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['question'] = question;
    data['prefill'] = prefill;
    return data;
  }
}
