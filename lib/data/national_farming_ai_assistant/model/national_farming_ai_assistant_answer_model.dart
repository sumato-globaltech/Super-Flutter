/// NationalFarmingAiAssistantAnswerModel as returned by the API.
class NationalFarmingAiAssistantAnswerModel {
  String? answer;

  NationalFarmingAiAssistantAnswerModel({this.answer});

  NationalFarmingAiAssistantAnswerModel.fromJson(Map<String, dynamic> json) {
    answer = json['answer'];
  }

  // sf:custom:begin NationalFarmingAiAssistantAnswerModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['answer'] = answer;
    return data;
  }
}
