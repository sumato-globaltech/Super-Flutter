import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/app/router/navigator_keys.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/data/farm/model/block_model.dart' as options;
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/data/profile/model/farmer_profile_model.dart'
    show FarmerProfileModel;
import 'package:super_flutter/data/profile/model/gender_model.dart';
import 'package:super_flutter/data/profile/model/land_ownership_model.dart';
import 'package:super_flutter/data/profile/sources/remote/profile_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/features/profile/presentation/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:super_flutter/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:super_flutter/features/profile/routes/profile_route_names.dart';
import 'package:super_flutter/features/profile/routes/profile_routes.dart';

class _MockProfile extends Mock implements ProfileRemoteDataSource {}

class _MockFarm extends Mock implements FarmRemoteDataSource {}

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

class _MockDio extends Mock implements Dio {}

class _MockClient extends Mock implements DioClient {}

void main() {
  late _MockProfile source;
  late _MockFarm farm;
  late _MockAuth auth;
  final profile = FarmerProfileModel.fromJson({
    'id': 'f1',
    'code': 'FRM-000001',
    'name': 'Vizo',
    'email': 'v@example.test',
    'gender': {'value': 'male', 'label': 'Male'},
    'date_of_birth': '1975-03-14',
    'districts': [
      {'id': 'd1', 'name': 'Kohima'},
    ],
    'blocks': [
      {'id': 'b1', 'name': 'Jakhama'},
      {'id': 'b2', 'name': 'Old block'},
    ],
    'village': 'Jakhama',
    'land_area_ha': 3,
    'is_verified': true,
  });

  setUp(() async {
    source = _MockProfile();
    farm = _MockFarm();
    auth = _MockAuth();
    await getIt.reset();
    getIt
      ..registerFactory(() => ProfileBloc(source))
      ..registerFactory(() => EditProfileBloc(source, farm));
    when(() => source.getFarmerProfile()).thenAnswer((_) async => profile);
    when(() => source.getGenders())
        .thenAnswer((_) async => [GenderModel(id: 'male', name: 'Male')]);
    when(
      () => source.getLandOwnerships(),
    ).thenAnswer((_) async => [LandOwnershipModel(id: 'owned', name: 'Owned')]);
    when(() => farm.getBlocks()).thenAnswer(
      (_) async => [
        options.BlockModel(id: 'b1', name: 'Jakhama'),
        options.BlockModel(id: 'b3', name: 'New block'),
      ],
    );
    when(() => auth.syncUser()).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    String role, {
    String location = ProfileRouteNames.root,
  }) async {
    when(() => auth.state).thenReturn(
      AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: 'u1',
          name: 'Vizo Angami',
          email: '',
          phone: '9876543210',
          role: UserRole(value: role, label: role),
          profileActive: true,
        ),
      ),
    );
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(
          theme: AppTheme.light(Flavor.development),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            navigatorKey: rootNavigatorKey,
            initialLocation: location,
            routes: buildProfileRoutes(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a farmer sees account and farmer details', (tester) async {
    await pump(tester, 'farmer');
    for (final text in [
      'Vizo Angami',
      '9876543210',
      'FRM-000001',
      'Jakhama, Old block',
      'Change password',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
  });

  testWidgets('others only have their account', (tester) async {
    await pump(tester, 'vendor');
    expect(find.text('Vizo Angami'), findsOneWidget);
    expect(find.text('Farmer details'), findsNothing);
    verifyNever(() => source.getFarmerProfile());
  });

  testWidgets('saving keeps every block and empties what was cleared', (
    tester,
  ) async {
    when(
      () => source.updateEditProfile(
        name: any(named: 'name'),
        email: any(named: 'email'),
        gender: any(named: 'gender'),
        dateOfBirth: any(named: 'dateOfBirth'),
        village: any(named: 'village'),
        address: any(named: 'address'),
        landAreaHa: any(named: 'landAreaHa'),
        landOwnership: any(named: 'landOwnership'),
        blockIds: any(named: 'blockIds'),
      ),
    ).thenAnswer((_) async => true);
    await pump(tester, 'farmer');
    await tester.tap(find.byTooltip('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.textContaining('You are verified'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('New block'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Village'), '');
    await tester.tap(find.byIcon(Icons.close));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(
      () => source.updateEditProfile(
        name: 'Vizo',
        email: 'v@example.test',
        gender: 'male',
        landAreaHa: 3,
        blockIds: ['b1', 'b2', 'b3'],
      ),
    ).called(1);
    verify(() => auth.syncUser()).called(1);
    verify(() => source.getFarmerProfile()).called(2);
  });

  testWidgets('the edit link without a profile opens the profile', (
    tester,
  ) async {
    await pump(tester, 'farmer', location: ProfileRouteNames.editProfile);
    expect(find.text('Farmer details'), findsOneWidget);
  });

  test('emptied fields are sent as null', () async {
    final dio = _MockDio();
    final client = _MockClient();
    when(() => client.dio).thenReturn(dio);
    when(() => dio.put<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
        data: {'success': true},
      ),
    );
    await ProfileRemoteDataSource(client)
        .updateEditProfile(name: 'Vizo', blockIds: const []);
    final data =
        verify(
              () => dio.put<dynamic>(
                '/api/v1/farmer/profile',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(data.containsKey('village') && data['village'] == null, isTrue);
    expect(data['block_ids'], isEmpty);
    expect(data.containsKey('block_id'), isFalse);
  });
}
