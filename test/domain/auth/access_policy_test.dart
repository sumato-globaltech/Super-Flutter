import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/domain/auth/entities/access_rule.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';

void main() {
  const farmer = AccessPolicy(
    isSignedIn: true,
    role: Roles.farmer,
    permissions: {Permissions.shipmentsRequest},
    profileActive: true,
  );

  group('rules', () {
    test('public allows everyone, signed in needs a session', () {
      expect(const AccessRule.public().allows(AccessPolicy.guest), isTrue);
      expect(const AccessRule.signedIn().allows(AccessPolicy.guest), isFalse);
      expect(const AccessRule.signedIn().allows(farmer), isTrue);
    });

    test('role, permission and profile check the policy', () {
      expect(const AccessRule.role(Roles.farmer).allows(farmer), isTrue);
      expect(const AccessRule.role(Roles.driver).allows(farmer), isFalse);
      expect(
        const AccessRule.permission(Permissions.shipmentsRequest)
            .allows(farmer),
        isTrue,
      );
      expect(
        const AccessRule.permission(Permissions.helpdeskManage).allows(farmer),
        isFalse,
      );
      expect(const AccessRule.profile().allows(farmer), isTrue);
    });

    test('a guest never passes role, permission or profile rules', () {
      const forged = AccessPolicy(
        isSignedIn: false,
        role: Roles.admin,
        permissions: {Permissions.helpdeskManage},
        profileActive: true,
      );
      expect(const AccessRule.role(Roles.admin).allows(forged), isFalse);
      expect(
        const AccessRule.permission(Permissions.helpdeskManage).allows(forged),
        isFalse,
      );
      expect(const AccessRule.profile().allows(forged), isFalse);
    });

    test('any and all combine rules', () {
      const anyProduction = AccessRule.any([
        AccessRule.permission(Permissions.productionView),
        AccessRule.permission(Permissions.productionManage),
      ]);
      const farmerWithProfile = AccessRule.all([
        AccessRule.role(Roles.farmer),
        AccessRule.profile(),
      ]);
      const manager = AccessPolicy(
        isSignedIn: true,
        role: Roles.districtOfficer,
        permissions: {Permissions.productionManage},
      );

      expect(anyProduction.allows(manager), isTrue);
      expect(anyProduction.allows(farmer), isFalse);
      expect(farmerWithProfile.allows(farmer), isTrue);
      expect(
        farmerWithProfile.allows(
          const AccessPolicy(isSignedIn: true, role: Roles.farmer),
        ),
        isFalse,
      );
    });

    test('an empty all rule allows nothing', () {
      expect(const AccessRule.all([]).allows(farmer), isFalse);
      expect(const AccessRule.any([]).allows(farmer), isFalse);
    });

    test('rules compare by value', () {
      expect(
        const AccessRule.role(Roles.farmer),
        const AccessRule.role(Roles.farmer),
      );
      expect(
        const AccessRule.all([AccessRule.profile()]),
        const AccessRule.all([AccessRule.profile()]),
      );
    });
  });

  group('AccessPolicy.fromUser', () {
    test('copies role, permissions and profile', () {
      const user = User(
        id: '1',
        name: 'Farmer',
        email: 'f@example.test',
        role: UserRole(value: Roles.farmer, label: 'Farmer'),
        permissions: {Permissions.shipmentsRequest},
        profileActive: true,
      );

      expect(AccessPolicy.fromUser(user), farmer);
      expect(
        AccessPolicy.fromUser(user).can(Permissions.shipmentsRequest),
        isTrue,
      );
    });

    test('a session without user details only counts as signed in', () {
      final policy = AccessPolicy.fromUser(null);

      expect(policy.isSignedIn, isTrue);
      expect(policy.role, isNull);
      expect(policy.permissions, isEmpty);
      expect(policy.profileActive, isFalse);
    });
  });
}
