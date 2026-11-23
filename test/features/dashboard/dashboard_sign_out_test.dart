import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/app_config.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/domain/auth/use_cases/logout.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:super_flutter/features/dashboard/presentation/dashboard/screen/dashboard_screen.dart';

class _Logout extends Mock implements Logout {}

void main() {
  late _Logout logout;

  setUp(() async {
    logout = _Logout();
    when(() => logout(allDevices: any(named: 'allDevices')))
        .thenAnswer((_) async {});
    await getIt.reset();
    getIt
      ..registerSingleton<AppConfig>(AppConfig.production())
      ..registerFactory<DashboardBloc>(() => DashboardBloc(logout));
  });

  Future<void> choose(WidgetTester tester, String item) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    );
    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  testWidgets('sign out asks first, then signs out here', (tester) async {
    await choose(tester, 'Sign out');
    expect(find.text('Sign out?'), findsOneWidget);
    expect(
      find.text('You will need to sign in again on this device.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign out'));
    await tester.pumpAndSettle();
    verify(() => logout(allDevices: false)).called(1);
  });

  testWidgets('sign out of all devices asks first', (tester) async {
    await choose(tester, 'Sign out of all devices');
    expect(find.text('Sign out of all devices?'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Sign out of all devices'),
    );
    await tester.pumpAndSettle();
    verify(() => logout(allDevices: true)).called(1);
  });

  testWidgets('dismissing the sheet signs nobody out', (tester) async {
    await choose(tester, 'Sign out of all devices');
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Sign out of all devices?'), findsNothing);
    verifyNever(() => logout(allDevices: any(named: 'allDevices')));
  });
}
