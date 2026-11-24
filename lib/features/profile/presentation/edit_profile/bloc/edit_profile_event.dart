import 'package:equatable/equatable.dart';

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileStarted extends EditProfileEvent {
  const EditProfileStarted();
}

class EditProfileFieldErrorCleared extends EditProfileEvent {
  const EditProfileFieldErrorCleared(this.field);

  final String field;

  @override
  List<Object?> get props => [field];
}

class EditProfileSubmitted extends EditProfileEvent {
  const EditProfileSubmitted({
    required this.name,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.village,
    this.address,
    this.landAreaHa,
    this.landOwnership,
    required this.blockIds,
  });

  final String name;
  final String? email;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? village;
  final String? address;
  final double? landAreaHa;
  final String? landOwnership;
  final List<String> blockIds;

  @override
  List<Object?> get props => [
    name,
    email,
    gender,
    dateOfBirth,
    village,
    address,
    landAreaHa,
    landOwnership,
    blockIds,
  ];
}
