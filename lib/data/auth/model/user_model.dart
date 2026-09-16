import 'package:json_annotation/json_annotation.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.image = '',
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    image: image,
  );
}
