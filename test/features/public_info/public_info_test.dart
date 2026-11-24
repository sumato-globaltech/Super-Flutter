import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/app_network_image.dart';
import 'package:super_flutter/data/facilities/model/facility_model.dart';
import 'package:super_flutter/data/facilities/model/facility_stats_model.dart';
import 'package:super_flutter/data/facilities/sources/remote/facilities_remote_data_source.dart';
import 'package:super_flutter/data/meetings/model/district_option_model.dart';
import 'package:super_flutter/data/meetings/model/meeting_model.dart';
import 'package:super_flutter/data/meetings/sources/remote/meetings_remote_data_source.dart';
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart'
    show FarmerProfileModel;
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';
import 'package:super_flutter/data/support/model/category_model.dart'
    as options;
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/features/facilities/presentation/facilities/bloc/facilities_bloc.dart';
import 'package:super_flutter/features/facilities/presentation/facility_stats/bloc/facility_stats_bloc.dart';
import 'package:super_flutter/features/facilities/routes/facilities_route_names.dart';
import 'package:super_flutter/features/facilities/routes/facilities_routes.dart';
import 'package:super_flutter/features/meetings/presentation/meetings/bloc/meetings_bloc.dart';
import 'package:super_flutter/features/meetings/routes/meetings_route_names.dart';
import 'package:super_flutter/features/meetings/routes/meetings_routes.dart';

class _MockFacilities extends Mock implements FacilitiesRemoteDataSource {}

class _MockMeetings extends Mock implements MeetingsRemoteDataSource {}

class _MockProfile extends Mock implements ProfileRemoteDataSource {}

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late _MockFacilities facilities;
  late _MockMeetings meetings;
  late _MockProfile profile;
  late _MockAuth auth;

  // Whole numbers, as the API sends them.
  final facility = FacilityModel.fromJson({
    'id': 'f1',
    'name': 'Cold store',
    'category': {'id': 'c1', 'name': 'Market yard'},
    'district': {'id': 'd1', 'name': 'Kohima'},
    'capacity_tpd': 2424,
    'storage_area_sqm': 10,
    'products': ['Rice'],
    'is_operational': true,
  });
  final meeting = MeetingModel.fromJson({
    'id': 'm1',
    'agenda': 'Seed plan',
    'starts_at': '2026-12-01T10:00:00+05:30',
    'link': 'https://meet.example',
    'status': {'value': 'scheduled', 'label': 'Scheduled'},
  });

  setUp(() async {
    facilities = _MockFacilities();
    meetings = _MockMeetings();
    profile = _MockProfile();
    auth = _MockAuth();
    await getIt.reset();
    getIt
      ..registerFactory(() => FacilitiesBloc(facilities, meetings))
      ..registerFactory(() => FacilityStatsBloc(facilities))
      ..registerFactory(() => MeetingsBloc(meetings, profile));
    when(() => meetings.getDistrictList()).thenAnswer(
      (_) async => [
        DistrictOptionModel(id: 'd1', name: 'Kohima'),
        DistrictOptionModel(id: 'd2', name: 'Mon'),
      ],
    );
    when(
      () => meetings.getMeetings(
        districtId: any(named: 'districtId'),
        page: 1,
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => Paged(items: [meeting]));
    when(() => facilities.getFacilityTypes()).thenAnswer(
      (_) async => [options.CategoryModel(id: 'c1', name: 'Market yard')],
    );
    when(
      () => facilities.getFacilities(
        categoryId: any(named: 'categoryId'),
        districtId: any(named: 'districtId'),
        page: 1,
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async => Paged(items: [facility]));
  });

  Future<void> pump(
    WidgetTester tester,
    String location, {
    bool farmer = false,
  }) async {
    when(() => auth.state).thenReturn(
      farmer
          ? const AuthState(
              status: AuthStatus.authenticated,
              user: User(
                id: 'u1',
                name: 'Vizo',
                email: '',
                role: UserRole(value: 'farmer', label: 'Farmer'),
                profileActive: true,
              ),
            )
          : const AuthState(status: AuthStatus.unauthenticated),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(
          theme: AppTheme.dark(Flavor.development),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: location,
            routes: [...buildFacilitiesRoutes(), ...buildMeetingsRoutes()],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a guest chooses a district for meetings', (tester) async {
    await pump(tester, MeetingsRouteNames.root);
    expect(find.text('Choose a district to see its meetings'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mon').last);
    await tester.pumpAndSettle();
    expect(find.text('Seed plan'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
    verifyNever(() => profile.getFarmerProfile());
    verify(
      () => meetings.getMeetings(
        districtId: 'd2',
        page: 1,
        perPage: any(named: 'perPage'),
      ),
    ).called(1);
  });

  testWidgets('a farmer starts with their own district', (tester) async {
    when(() => profile.getFarmerProfile()).thenAnswer(
      (_) async => FarmerProfileModel.fromJson({
        'district': {'id': 'd1', 'name': 'Kohima'},
      }),
    );
    await pump(tester, MeetingsRouteNames.root, farmer: true);
    expect(find.text('Kohima'), findsOneWidget);
    expect(find.text('Seed plan'), findsOneWidget);
  });

  testWidgets('facilities filter, and whole-number capacities parse', (
    tester,
  ) async {
    await pump(tester, FacilitiesRouteNames.root);
    expect(find.text('Cold store'), findsOneWidget);
    expect(find.text('2,424 tonnes/day · 10 m² storage'), findsOneWidget);
    await tester.tap(find.text('All types'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market yard').last);
    await tester.pumpAndSettle();
    verify(
      () => facilities.getFacilities(
        categoryId: 'c1',
        page: 1,
        perPage: any(named: 'perPage'),
      ),
    ).called(1);
  });

  testWidgets('facilities show when their filters fail to load', (
    tester,
  ) async {
    when(() => facilities.getFacilityTypes())
        .thenAnswer((_) async => throw const ValidationException('No.'));
    when(() => meetings.getDistrictList())
        .thenAnswer((_) async => throw Exception());
    await pump(tester, FacilitiesRouteNames.root);
    expect(find.text('Cold store'), findsOneWidget);
  });

  testWidgets('statistics open from the list', (tester) async {
    when(() => facilities.getFacilityStats()).thenAnswer(
      (_) async => FacilityStatsModel.fromJson({
        'total': 2,
        'operational': 1,
        'by_category': [
          {
            'id': 'c1',
            'name': 'Cold storage',
            'total': 2,
            'operational': 1,
            'capacity_tpd': 5,
            'storage_area_sqm': 0,
          },
        ],
        'by_district': <Map<String, dynamic>>[],
      }),
    );
    await pump(tester, FacilitiesRouteNames.root);
    await tester.tap(find.byTooltip('Statistics'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 2 operational · 5 tonnes/day'), findsOneWidget);
    expect(find.text('By district'), findsNothing);
  });

  testWidgets('a full-width network image builds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(Flavor.development),
        home: const AppNetworkImage(
          url: 'https://x/c',
          width: double.infinity,
          height: 140,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
