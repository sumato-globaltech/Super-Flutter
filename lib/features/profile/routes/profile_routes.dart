import 'package:go_router/go_router.dart';
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart';
import 'package:super_flutter/features/profile/presentation/edit_profile/screen/edit_profile_screen.dart';
import 'package:super_flutter/features/profile/presentation/profile/screen/profile_screen.dart';

import 'profile_route_names.dart';

/// GoRoutes owned by the profile feature.
List<GoRoute> buildProfileRoutes() => [
  GoRoute(
    path: ProfileRouteNames.root,
    name: ProfileRouteNames.root,
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: ProfileRouteNames.editProfile,
    name: ProfileRouteNames.editProfile,
    // Saving replaces every field, so it starts from the loaded profile.
    redirect: (context, state) =>
        state.extra is FarmerProfileModel ? null : ProfileRouteNames.root,
    builder: (context, state) =>
        EditProfileScreen(profile: state.extra! as FarmerProfileModel),
  ),
];
