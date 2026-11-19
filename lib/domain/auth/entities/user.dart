import 'package:equatable/equatable.dart';

class UserRole extends Equatable {
  const UserRole({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.designation,
    this.role,
    this.photoUrl,
    this.emailVerified = false,
    this.passwordChangeRequired = false,
    this.createdAt,
  });

  static const empty = User(id: '', name: '', email: '');

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? designation;
  final UserRole? role;
  final String? photoUrl;
  final bool emailVerified;
  final bool passwordChangeRequired;
  final DateTime? createdAt;

  bool get isEmpty => this == empty;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    designation,
    role,
    photoUrl,
    emailVerified,
    passwordChangeRequired,
    createdAt,
  ];
}
