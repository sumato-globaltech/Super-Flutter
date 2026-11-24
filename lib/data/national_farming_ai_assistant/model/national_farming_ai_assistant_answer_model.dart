/// VistaarAnswerModel as returned by the API.
class VistaarAnswerModel {
  String? answer;

  VistaarAnswerModel({this.answer});

  VistaarAnswerModel.fromJson(Map<String, dynamic> json) {
    answer = json['answer'];
  }

  // sf:custom:begin VistaarAnswerModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['answer'] = answer;
    return data;
  }
}
