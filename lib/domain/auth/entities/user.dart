import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.image = '',
  });

  static const empty = User(id: 0, username: '', email: '');

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;

  bool get isEmpty => this == empty;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
