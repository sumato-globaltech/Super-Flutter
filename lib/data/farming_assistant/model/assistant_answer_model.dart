/// AssistantAnswerModel as returned by the API.
class AssistantAnswerModel {
  String? answer;

  AssistantAnswerModel({this.answer});

  AssistantAnswerModel.fromJson(Map<String, dynamic> json) {
    answer = json['answer'];
  }

  // sf:custom:begin AssistantAnswerModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['answer'] = answer;
    return data;
  }
}
