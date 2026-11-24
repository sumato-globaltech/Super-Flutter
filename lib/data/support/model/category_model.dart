/// CategoryModel as returned by the API.
class CategoryModel {
  String? id;
  String? type;
  String? name;
  String? slug;

  CategoryModel({this.id, this.type, this.name, this.slug});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    slug = json['slug'];
  }

  // sf:custom:begin CategoryModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}
