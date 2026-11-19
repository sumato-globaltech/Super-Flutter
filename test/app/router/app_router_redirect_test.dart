import 'package:flutter_test/flutter_test.dart';
import 'package:super_flutter/app/router/app_router.dart';
import 'package:super_flutter/app/router/routes_names.dart';
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
    test('force update wins over everything', () {
      expect(redirect(dashboard, AuthStatus.authenticated, update: true),
          RouteNames.forceUpdate);
      expect(redirect(RouteNames.forceUpdate, AuthStatus.authenticated,
          update: true), isNull);
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

    test('unknown status waits on splash', () {
      expect(redirect(dashboard, AuthStatus.unknown), RouteNames.splash);
      expect(redirect(RouteNames.splash, AuthStatus.unknown), isNull);
    });
  });
}
