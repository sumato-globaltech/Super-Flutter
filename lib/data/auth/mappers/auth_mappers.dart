import 'package:super_flutter/domain/auth/entities/auth_session.dart';
import 'package:super_flutter/domain/auth/entities/auth_token.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';

import '../model/login_model.dart';
import '../model/user_model.dart';

extension LoginModelMapper on LoginModel {
  AuthTokens toTokens() => AuthTokens(
    accessToken: accessToken ?? '',
    tokenType: tokenType ?? 'Bearer',
    expiresAt: expiresAt,
  );

  AuthSession toEntity() => AuthSession(
    user: user?.toEntity() ?? User.empty,
    tokens: toTokens(),
    passwordChangeRequired: passwordChangeRequired ?? false,
  );
}

extension UserModelMapper on UserModel {
  User toEntity() => User(
    id: id ?? '',
    name: name ?? '',
    email: email ?? '',
    phone: phone,
    designation: designation,
    role: role?.toEntity(),
    photoUrl: photoUrl,
    emailVerified: emailVerified ?? false,
    passwordChangeRequired: passwordChangeRequired ?? false,
    createdAt: createdAt,
  );
}

extension RoleModelMapper on RoleModel {
  UserRole toEntity() => UserRole(value: value ?? '', label: label ?? '');
}
