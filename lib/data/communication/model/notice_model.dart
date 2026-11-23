/// NoticeModel as returned by the API.
class NoticeModel {
  String? id;
  String? title;
  CategoryModel? category;
  PriorityModel? priority;
  DateTime? publishedAt;
  DateTime? expiresAt;
  String? body;

  NoticeModel({
    this.id,
    this.title,
    this.category,
    this.priority,
    this.publishedAt,
    this.expiresAt,
    this.body,
  });

  NoticeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    priority = json['priority'] != null
        ? PriorityModel.fromJson(json['priority'])
        : null;
    publishedAt = json['published_at'] != null
        ? DateTime.tryParse(json['published_at'].toString())
        : null;
    expiresAt = json['expires_at'] != null
        ? DateTime.tryParse(json['expires_at'].toString())
        : null;
    body = json['body'];
  }

  // sf:custom:begin NoticeModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (priority != null) {
      data['priority'] = priority!.toJson();
    }
    data['published_at'] = publishedAt?.toIso8601String();
    data['expires_at'] = expiresAt?.toIso8601String();
    data['body'] = body;
    return data;
  }
}

class CategoryModel {
  String? id;
  String? name;

  CategoryModel({this.id, this.name});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  // sf:custom:begin CategoryModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class PriorityModel {
  String? value;
  String? label;

  PriorityModel({this.value, this.label});

  PriorityModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin PriorityModel
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
