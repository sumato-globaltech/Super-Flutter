import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/app/access/app_features.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';

/// Role defaults from `dam/config/access.php`, as the API returns them.
const _defaults = <String, Set<String>>{
  Roles.admin: {
    'dashboard.view', 'users.view', 'users.create', 'users.edit', //
    'geography.view', 'geography.manage', 'units.manage',
    'categories.manage', 'otp.test_numbers', 'crops.view', 'crops.manage',
    'crops.verify', 'farmers.view', 'farmers.manage', 'farmers.verify',
    'production.view', 'production.manage', 'markets.view', 'markets.manage',
    'schemes.view', 'schemes.manage', 'schemes.review', 'notices.manage',
    'alerts.manage', 'advisories.send', 'banners.manage',
    'publications.manage', 'meetings.view', 'meetings.manage',
    'helpdesk.view', 'helpdesk.manage', 'facilities.view',
    'facilities.manage', 'vehicles.view', 'vehicles.manage', 'vendors.view',
    'vendors.manage', 'vendors.score', 'shipments.view', 'drivers.view',
    'drivers.manage', 'devices.view',
  },
  Roles.districtOfficer: {
    'dashboard.view', 'geography.view', 'crops.view', 'farmers.view', //
    'farmers.manage', 'production.manage', 'markets.view', 'schemes.view',
    'schemes.review', 'alerts.manage', 'advisories.send', 'meetings.view',
    'meetings.manage', 'helpdesk.view', 'facilities.view',
    'facilities.manage', 'vehicles.view', 'vendors.view', 'vendors.manage',
    'vendors.score', 'shipments.view', 'drivers.view', 'drivers.manage',
    'devices.view',
  },
  Roles.callCenterAgent: {
    'dashboard.view', 'crops.view', 'farmers.view', 'farmers.manage', //
    'markets.view', 'schemes.view', 'meetings.view', 'helpdesk.view',
    'helpdesk.manage', 'facilities.view', 'devices.view',
  },
  Roles.farmer: {'shipments.request'},
  Roles.vendor: {
    'shipments.handle', 'vehicles.view', 'vehicles.manage', //
    'drivers.view', 'drivers.manage',
  },
  Roles.driver: {'shipments.drive'},
};

AccessPolicy policyFor(String role, {bool profile = false}) => AccessPolicy(
  isSignedIn: true,
  role: role,
  permissions: role == Roles.superAdmin
      ? _defaults.values.expand((p) => p).toSet().union({
          'shipments.request',
          'shipments.handle',
          'shipments.drive',
        })
      : _defaults[role]!,
  profileActive: profile,
);

List<String> tabsOf(AccessPolicy policy) =>
    appFeatures.navigationFor(policy).tabs.map((f) => f.id).toList();

void main() {
  group('bottom bar per role', () {
    test('farmer with an active profile', () {
      expect(tabsOf(policyFor(Roles.farmer, profile: true)), [
        'home',
        'farms',
        'farmer_shipments',
        'market',
        'schemes',
      ]);
    });

    test('farmer without a profile gets no farmer features', () {
      expect(tabsOf(policyFor(Roles.farmer)), ['home', 'market', 'schemes']);
    });

    test('vendor and driver see their own shipments', () {
      expect(tabsOf(policyFor(Roles.vendor, profile: true)), [
        'home',
        'vendor_shipments',
        'market',
        'schemes',
      ]);
      expect(tabsOf(policyFor(Roles.driver, profile: true)), [
        'home',
        'driver_shipments',
        'market',
        'schemes',
      ]);
    });

    test('call centre agent gets the help desk queue', () {
      expect(tabsOf(policyFor(Roles.callCenterAgent)), [
        'home',
        'help_desk_queue',
        'market',
        'schemes',
      ]);
    });

    test('district officer gets production', () {
      expect(tabsOf(policyFor(Roles.districtOfficer)), [
        'home',
        'production',
        'market',
        'schemes',
      ]);
    });

    test('admin and super admin fit in five tabs without shipments', () {
      const expected = [
        'home',
        'production',
        'help_desk_queue',
        'market',
        'schemes',
      ];
      expect(tabsOf(policyFor(Roles.admin)), expected);
      final superAdmin = appFeatures.navigationFor(policyFor(Roles.superAdmin));
      expect(superAdmin.tabs.map((f) => f.id), expected);
      expect(superAdmin.hasMore, isFalse);
    });

    test('a session without details still gets home and public tabs', () {
      expect(tabsOf(AccessPolicy.signedInWithoutDetails), [
        'home',
        'market',
        'schemes',
      ]);
    });

    test('every role gets at least two tabs', () {
      for (final role in [..._defaults.keys, Roles.superAdmin]) {
        expect(
          tabsOf(policyFor(role, profile: true)).length,
          inInclusiveRange(2, 5),
          reason: role,
        );
      }
    });
  });

  group('other destinations', () {
    test('farmer reaches support, crops, notices and profile', () {
      final ids = appFeatures
          .secondary(policyFor(Roles.farmer, profile: true))
          .map((f) => f.id);
      expect(ids, containsAll(['support', 'crops', 'notices', 'profile']));
      expect(ids, isNot(contains('manage_notices')));
    });

    test('admin can manage notices and alerts', () {
      final ids = appFeatures
          .secondary(policyFor(Roles.admin))
          .map((f) => f.id);
      expect(ids, containsAll(['manage_notices', 'manage_alerts']));
      expect(ids, isNot(contains('support')));
    });
  });

  group('quick actions on Home', () {
    List<String> actionsOf(AccessPolicy policy) => appFeatures
        .quickActions(policy, home: DashboardRouteNames.dashboard)
        .map((f) => f.id)
        .toList();

    test('a farmer gets what the tab bar does not show', () {
      final ids = actionsOf(policyFor(Roles.farmer, profile: true));
      expect(ids, [
        'support',
        'crops',
        'geo_map',
        'notices',
        'profile',
        'farm_add_farm',
        'shipments_request_shipment',
        'schemes_my_applications',
        'meetings',
        'facilities',
      ]);
    });

    test('screens that need an id in their path are never quick actions', () {
      final actions = appFeatures.quickActions(
        policyFor(Roles.farmer, profile: true),
        home: DashboardRouteNames.dashboard,
      );
      expect(actions.where((f) => f.path.contains('/:')), isEmpty);
      expect(
        actions.map((f) => f.id),
        isNot(contains('shipments_shipment_detail')),
      );
    });

    test('an admin gets the management screens, not the farmer ones', () {
      final ids = actionsOf(policyFor(Roles.admin));
      expect(ids, containsAll(['manage_notices', 'manage_alerts']));
      expect(ids, isNot(contains('support')));
      expect(ids, isNot(contains('home')));
    });

    test('tabs behind More come first, once per path', () {
      final policy = policyFor(Roles.superAdmin, profile: true);
      final overflow = appFeatures
          .navigationFor(policy, maxTabs: 3)
          .overflow
          .map((f) => f.path)
          .toSet();
      final actions = appFeatures.quickActions(
        policy,
        home: DashboardRouteNames.dashboard,
        maxTabs: 3,
      );
      expect(overflow, isNotEmpty);
      expect(
        actions.take(overflow.length).map((f) => f.path).toSet(),
        overflow,
      );
      final paths = actions.map((f) => f.path).toList();
      expect(paths.toSet().length, paths.length);
    });
  });

  group('route guard', () {
    test('farmers, vendors and drivers open a shipment, others do not', () {
      const path = '/shipments/shipment_detail/01ABC';
      expect(
        appFeatures.canOpen(path, policyFor(Roles.farmer, profile: true)),
        isTrue,
      );
      expect(
        appFeatures.canOpen(path, policyFor(Roles.vendor, profile: true)),
        isTrue,
      );
      expect(
        appFeatures.canOpen(path, policyFor(Roles.driver, profile: true)),
        isTrue,
      );
      expect(appFeatures.canOpen(path, policyFor(Roles.vendor)), isFalse);
    });

    test('only farmers with a profile open farm routes', () {
      final farmer = policyFor(Roles.farmer, profile: true);
      expect(appFeatures.canOpen('/farms', farmer), isTrue);
      expect(appFeatures.canOpen('/farms/01ABC/crops', farmer), isTrue);
      expect(appFeatures.canOpen('/farms', policyFor(Roles.farmer)), isFalse);
      expect(appFeatures.canOpen('/farms', policyFor(Roles.admin)), isFalse);
    });

    test('shipments open for whichever party the user is', () {
      for (final role in [Roles.farmer, Roles.vendor, Roles.driver]) {
        expect(
          appFeatures.canOpen(
            '/shipments/01XYZ',
            policyFor(role, profile: true),
          ),
          isTrue,
          reason: role,
        );
      }
      expect(
        appFeatures.canOpen('/shipments', policyFor(Roles.admin)),
        isFalse,
      );
    });

    test('admin routes need their permission', () {
      expect(
        appFeatures.canOpen('/admin/notices', policyFor(Roles.admin)),
        isTrue,
      );
      expect(
        appFeatures.canOpen('/admin/notices', policyFor(Roles.districtOfficer)),
        isFalse,
      );
      expect(
        appFeatures.canOpen('/admin/alerts', policyFor(Roles.districtOfficer)),
        isTrue,
      );
    });

    test('routes no feature claims are left to the router', () {
      expect(appFeatures.canOpen('/login', AccessPolicy.guest), isTrue);
      expect(appFeatures.canOpen('/ui_gallery', AccessPolicy.guest), isTrue);
    });

    test('query strings do not change the decision', () {
      expect(
        appFeatures.canOpen('/farms?tab=crops', policyFor(Roles.driver)),
        isFalse,
      );
      expect(
        appFeatures.canOpen('/market?crop=paddy', AccessPolicy.guest),
        isTrue,
      );
    });
  });
}
