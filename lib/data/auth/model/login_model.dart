import 'package:super_flutter/data/auth/model/user_model.dart';

/// LoginModel as returned by the API.
class LoginModel {
  String? tokenType;
  String? accessToken;
  DateTime? expiresAt;
  bool? passwordChangeRequired;
  UserModel? user;

  LoginModel({
    this.tokenType,
    this.accessToken,
    this.expiresAt,
    this.passwordChangeRequired,
    this.user,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    tokenType = json['token_type'];
    accessToken = json['access_token'];
    expiresAt = json['expires_at'] != null
        ? DateTime.tryParse(json['expires_at'].toString())
        : null;
    passwordChangeRequired = json['password_change_required'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  // sf:custom:begin LoginModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token_type'] = tokenType;
    data['access_token'] = accessToken;
    data['expires_at'] = expiresAt?.toIso8601String();
    data['password_change_required'] = passwordChangeRequired;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
