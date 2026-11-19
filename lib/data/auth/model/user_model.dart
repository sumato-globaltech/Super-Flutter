/// UserModel as returned by the API.
class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? designation;
  RoleModel? role;
  String? photoUrl;
  bool? emailVerified;
  bool? passwordChangeRequired;
  DateTime? createdAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.designation,
    this.role,
    this.photoUrl,
    this.emailVerified,
    this.passwordChangeRequired,
    this.createdAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    designation = json['designation'];
    role = json['role'] != null ? RoleModel.fromJson(json['role']) : null;
    photoUrl = json['photo_url'];
    emailVerified = json['email_verified'];
    passwordChangeRequired = json['password_change_required'];
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
  }

  // sf:custom:begin UserModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['designation'] = designation;
    if (role != null) {
      data['role'] = role!.toJson();
    }
    data['photo_url'] = photoUrl;
    data['email_verified'] = emailVerified;
    data['password_change_required'] = passwordChangeRequired;
    data['created_at'] = createdAt?.toIso8601String();
    return data;
  }
}

class RoleModel {
  String? value;
  String? label;

  RoleModel({this.value, this.label});

  RoleModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  // sf:custom:begin RoleModel
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
