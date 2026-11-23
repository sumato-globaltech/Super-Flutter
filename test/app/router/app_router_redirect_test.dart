import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/app/router/app_router.dart';
import 'package:super_flutter/app/router/routes_names.dart';
import 'package:super_flutter/domain/auth/entities/access_policy.dart';
import 'package:super_flutter/features/auth/routes/auth_route_names.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/features/dashboard/routes/dashboard_route_names.dart';

void main() {
  const login = AuthRouteNames.login;
  const dashboard = DashboardRouteNames.dashboard;

  String? redirect(String location, AuthStatus status, {bool update = false}) =>
      resolveRedirect(
        location: location,
        status: status,
        updateRequired: update,
      );

  group('resolveRedirect', () {
    test('a password that must change holds the user on its screen', () {
      const change = AuthRouteNames.changePassword;
      String? forced(String location) => resolveRedirect(
        location: location,
        status: AuthStatus.authenticated,
        updateRequired: false,
        passwordChangeRequired: true,
      );
      expect(forced(dashboard), change);
      expect(forced(login), change);
      expect(forced(RouteNames.splash), change);
      expect(forced(change), isNull);

      // Changed, the screen lets go; it can still be opened on purpose.
      expect(redirect(change, AuthStatus.authenticated), isNull);
      expect(redirect(login, AuthStatus.authenticated), dashboard);
      // Signed out from it, the user goes to login.
      expect(redirect(change, AuthStatus.unauthenticated), login);
    });

    test('force update wins over everything', () {
      expect(
        redirect(dashboard, AuthStatus.authenticated, update: true),
        RouteNames.forceUpdate,
      );
      expect(
        redirect(
          RouteNames.forceUpdate,
          AuthStatus.authenticated,
          update: true,
        ),
        isNull,
      );
    });

    test('app launch opens login or dashboard directly', () {
      expect(redirect(RouteNames.splash, AuthStatus.unauthenticated), login);
      expect(redirect(RouteNames.splash, AuthStatus.authenticated), dashboard);
    });

    test('unauthenticated users are kept on login', () {
      expect(redirect(dashboard, AuthStatus.unauthenticated), login);
      expect(redirect(login, AuthStatus.unauthenticated), isNull);
    });

    test('authenticated users leave login and can browse freely', () {
      expect(redirect(login, AuthStatus.authenticated), dashboard);
      expect(redirect(dashboard, AuthStatus.authenticated), isNull);
      expect(redirect('/anything', AuthStatus.authenticated), isNull);
    });

    group('access', () {
      const farmer = AccessPolicy(
        isSignedIn: true,
        role: Roles.farmer,
        permissions: {Permissions.shipmentsRequest},
        profileActive: true,
      );
      const driver = AccessPolicy(
        isSignedIn: true,
        role: Roles.driver,
        permissions: {Permissions.shipmentsDrive},
        profileActive: true,
      );

      String? open(String location, AccessPolicy access) => resolveRedirect(
        location: location,
        status: AuthStatus.authenticated,
        updateRequired: false,
        access: access,
      );

      test('allowed routes open', () {
        expect(open('/farms', farmer), isNull);
        expect(open('/farms/01ABC', farmer), isNull);
        expect(open('/shipments', driver), isNull);
        expect(open('/market', driver), isNull);
      });

      test('a route the user may not use goes home', () {
        expect(open('/farms', driver), dashboard);
        expect(open('/help-desk', farmer), dashboard);
        expect(open('/admin/notices', farmer), dashboard);
      });

      test('home never redirects, even without user details', () {
        expect(open(dashboard, AccessPolicy.signedInWithoutDetails), isNull);
        expect(open(dashboard, const AccessPolicy(isSignedIn: true)), isNull);
      });

      test('without details only public and signed-in routes open', () {
        expect(open('/market', AccessPolicy.signedInWithoutDetails), isNull);
        expect(open('/farms', AccessPolicy.signedInWithoutDetails), dashboard);
      });
    });

    test('unknown status waits on splash', () {
      expect(redirect(dashboard, AuthStatus.unknown), RouteNames.splash);
      expect(redirect(RouteNames.splash, AuthStatus.unknown), isNull);
    });
  });
}
