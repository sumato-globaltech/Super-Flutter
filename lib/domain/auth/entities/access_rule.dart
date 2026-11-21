import 'package:equatable/equatable.dart';

import 'access_policy.dart';

/// What a feature needs before the user may see or open it. Rules mirror the
/// backend: a role (`App\Enums\UserRole`), a permission (`config/access.php`)
/// or an active farmer/vendor/driver profile (`profile_active`).
sealed class AccessRule extends Equatable {
  const AccessRule();

  const factory AccessRule.public() = PublicRule;
  const factory AccessRule.signedIn() = SignedInRule;
  const factory AccessRule.role(String role) = RoleRule;
  const factory AccessRule.permission(String permission) = PermissionRule;
  const factory AccessRule.profile() = ProfileRule;
  const factory AccessRule.any(List<AccessRule> rules) = AnyRule;
  const factory AccessRule.all(List<AccessRule> rules) = AllRule;

  bool allows(AccessPolicy policy);
}

final class PublicRule extends AccessRule {
  const PublicRule();

  @override
  bool allows(AccessPolicy policy) => true;

  @override
  List<Object?> get props => const [];
}

final class SignedInRule extends AccessRule {
  const SignedInRule();

  @override
  bool allows(AccessPolicy policy) => policy.isSignedIn;

  @override
  List<Object?> get props => const [];
}

final class RoleRule extends AccessRule {
  const RoleRule(this.role);

  final String role;

  @override
  bool allows(AccessPolicy policy) => policy.isSignedIn && policy.role == role;

  @override
  List<Object?> get props => [role];
}

final class PermissionRule extends AccessRule {
  const PermissionRule(this.permission);

  final String permission;

  @override
  bool allows(AccessPolicy policy) =>
      policy.isSignedIn && policy.permissions.contains(permission);

  @override
  List<Object?> get props => [permission];
}

final class ProfileRule extends AccessRule {
  const ProfileRule();

  @override
  bool allows(AccessPolicy policy) => policy.isSignedIn && policy.profileActive;

  @override
  List<Object?> get props => const [];
}

final class AnyRule extends AccessRule {
  const AnyRule(this.rules);

  final List<AccessRule> rules;

  @override
  bool allows(AccessPolicy policy) => rules.any((rule) => rule.allows(policy));

  @override
  List<Object?> get props => [rules];
}

final class AllRule extends AccessRule {
  const AllRule(this.rules);

  final List<AccessRule> rules;

  @override
  bool allows(AccessPolicy policy) =>
      rules.isNotEmpty && rules.every((rule) => rule.allows(policy));

  @override
  List<Object?> get props => [rules];
}
