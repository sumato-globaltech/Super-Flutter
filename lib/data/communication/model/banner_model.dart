/// BannerModel as returned by the API.
class BannerModel {
  String? id;
  String? title;
  String? linkUrl;
  String? imageUrl;
  String? startsOn;
  String? endsOn;

  BannerModel({
    this.id,
    this.title,
    this.linkUrl,
    this.imageUrl,
    this.startsOn,
    this.endsOn,
  });

  BannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    linkUrl = json['link_url'];
    imageUrl = json['image_url'];
    startsOn = json['starts_on'];
    endsOn = json['ends_on'];
  }

  // sf:custom:begin BannerModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['link_url'] = linkUrl;
    data['image_url'] = imageUrl;
    data['starts_on'] = startsOn;
    data['ends_on'] = endsOn;
    return data;
  }
}
