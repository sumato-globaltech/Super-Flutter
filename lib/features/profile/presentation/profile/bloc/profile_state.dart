import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final ProfileStatus status;
  final FarmerProfileModel? profile;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    FarmerProfileModel? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
