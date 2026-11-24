import 'package:equatable/equatable.dart';

import 'access_rule.dart';
import 'user.dart';

/// Role values sent by the API (`App\Enums\UserRole`).
abstract final class Roles {
  static const superAdmin = 'super-admin';
  static const admin = 'admin';
  static const stateOfficer = 'state_officer';
  static const districtOfficer = 'district_officer';
  static const callCenterAgent = 'call_center_agent';
  static const farmer = 'farmer';
  static const vendor = 'vendor';
  static const driver = 'driver';
}

/// Permissions the app checks (`<module>.<feature>` in `config/access.php`).
abstract final class Permissions {
  static const schemesView = 'schemes.view';
  static const productionView = 'production.view';
  static const productionManage = 'production.manage';
  static const helpdeskManage = 'helpdesk.manage';
  static const noticesManage = 'notices.manage';
  static const alertsManage = 'alerts.manage';
  static const cropDetectorUse = 'crop_detector.use';
  static const shipmentsRequest = 'shipments.request';
  static const shipmentsHandle = 'shipments.handle';
  static const shipmentsDrive = 'shipments.drive';
}

/// What the signed-in user may do, as the API reported it on login or `/me`.
class AccessPolicy extends Equatable {
  const AccessPolicy({
    required this.isSignedIn,
    this.role,
    this.permissions = const {},
    this.profileActive = false,
  });

  factory AccessPolicy.fromUser(User? user) => user == null
      ? AccessPolicy.signedInWithoutDetails
      : AccessPolicy(
          isSignedIn: true,
          role: user.role?.value,
          permissions: user.permissions,
          profileActive: user.profileActive,
        );

  static const guest = AccessPolicy(isSignedIn: false);

  /// Signed in, but the user details are not known yet: only rules that need
  /// nothing more than a session pass.
  static const signedInWithoutDetails = AccessPolicy(isSignedIn: true);

  final bool isSignedIn;
  final String? role;
  final Set<String> permissions;
  final bool profileActive;

  bool allows(AccessRule rule) => rule.allows(this);

  bool can(String permission) => allows(AccessRule.permission(permission));

  @override
  List<Object?> get props => [isSignedIn, role, permissions, profileActive];
}
