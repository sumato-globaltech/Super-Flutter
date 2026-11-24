/// PublicationModel as returned by the API.
class PublicationModel {
  String? id;
  String? title;
  String? summary;
  String? leftText;
  String? rightText;
  String? coverUrl;
  String? pdfUrl;

  PublicationModel({
    this.id,
    this.title,
    this.summary,
    this.leftText,
    this.rightText,
    this.coverUrl,
    this.pdfUrl,
  });

  PublicationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    summary = json['summary'];
    leftText = json['left_text'];
    rightText = json['right_text'];
    coverUrl = json['cover_url'];
    pdfUrl = json['pdf_url'];
  }

  // sf:custom:begin PublicationModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['summary'] = summary;
    data['left_text'] = leftText;
    data['right_text'] = rightText;
    data['cover_url'] = coverUrl;
    data['pdf_url'] = pdfUrl;
    return data;
  }
}
