import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/data/auth/mappers/auth_mappers.dart';
import 'package:super_flutter/data/auth/model/user_model.dart';

void main() {
  final json = <String, dynamic>{
    'id': '01m6de2ppp3mndabp9k5gpq9r3',
    'name': 'Sample Farmer',
    'email': 'farmer@example.test',
    'phone': '9876543210',
    'designation': null,
    'role': {'value': 'farmer', 'label': 'Farmer'},
    'permissions': ['shipments.request'],
    'profile_active': true,
    'photo_url': null,
    'email_verified': true,
    'password_change_required': false,
    'created_at': '2026-11-21T10:00:00+00:00',
  };

  test('reads role, permissions and profile from the API user', () {
    final user = UserModel.fromJson(json);

    expect(user.role?.value, 'farmer');
    expect(user.permissions, ['shipments.request']);
    expect(user.profileActive, isTrue);
  });

  test('keeps access through the cached user round trip', () {
    final cached = UserModel.fromJson(UserModel.fromJson(json).toJson());

    expect(cached.role?.label, 'Farmer');
    expect(cached.permissions, ['shipments.request']);
    expect(cached.profileActive, isTrue);
  });

  test('maps access into the domain user', () {
    final user = UserModel.fromJson(json).toEntity();

    expect(user.role?.value, 'farmer');
    expect(user.permissions, {'shipments.request'});
    expect(user.profileActive, isTrue);
  });

  test('an older cached user without access fields still reads', () {
    final legacy = Map<String, dynamic>.from(json)
      ..remove('permissions')
      ..remove('profile_active');

    final user = UserModel.fromJson(legacy);

    expect(user.permissions, isNull);
    expect(user.profileActive, isNull);
    expect(user.toEntity().permissions, isEmpty);
    expect(user.toEntity().profileActive, isFalse);
  });
}
