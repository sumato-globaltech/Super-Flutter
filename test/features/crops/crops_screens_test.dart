import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_fertilizers_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/model/crop_recommendation_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/bloc/crop_detail_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crop_detail/screen/crop_detail_screen.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/bloc/crop_recommendations_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crop_recommendations/screen/crop_recommendations_screen.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/bloc/crops_list_bloc.dart';
import 'package:super_flutter/features/crops/presentation/crops_list/screen/crops_list_screen.dart';

class _MockCropSource extends Mock implements CropRemoteDataSource {}

final _crop = CropModel(
  id: 'c1',
  name: 'Ginger',
  slug: 'ginger',
  scientificName: 'Zingiber officinale',
  type: const CropTypeModel(id: 't1', name: 'Spices', slug: 'spices'),
  durationDays: 240,
  summary: 'A spicy rhizome widely cultivated.',
  varieties: const [
    CropVarietyModel(name: 'Nadia', durationDays: 220, yieldPerHa: '15 t/ha'),
  ],
);

final _advisory = CropAdvisoryModel(
  crop: _crop,
  month: const MonthModel(number: 11, name: 'November'),
  windows: const WindowsModel(sowing: 'April - May', harvest: 'December - January'),
  profile: const CropProfileModel(
    climate: CropClimateModel(tempMinC: 15, tempMaxC: 35),
    soil: CropSoilModel(types: ['Loamy', 'Sandy loam'], phMin: 5.5, phMax: 6.5),
    sowing: CropSowingModel(method: 'Raised bed planting', seedRateKgHa: 1500),
  ),
  fertilizers: const [
    CropFertilizerGroupModel(
      label: 'Basal Application',
      items: [
        CropFertilizerItemModel(
          fertilizer: 'FYM / Compost',
          dosage: '25-30 t/ha',
        ),
      ],
    ),
  ],
);

final _recommendationResult = CropRecommendationResultModel(
  input: const CropRecommendationInputModel(
    district: DistrictModel(id: '01m6de2pq2ewspmabq763tymyn', name: 'Longleng'),
    sowingMonth: MonthModel(number: 11, name: 'November'),
    areaHa: 1.0,
  ),
  results: [
    CropRecommendationItemModel(
      rank: 1,
      crop: _crop,
      suitabilityScore: 95,
      suitabilityLabel: 'High',
      sowingWindow: 'Nov - Dec',
      notes: const ['Highly suitable for current soil and season'],
    ),
  ],
);

void main() {
  late _MockCropSource source;

  setUp(() async {
    source = _MockCropSource();
    await getIt.reset();
    getIt.registerLazySingleton<CropRemoteDataSource>(() => source);
    getIt.registerFactory<CropsListBloc>(() => CropsListBloc(source));
    getIt.registerFactory<CropDetailBloc>(() => CropDetailBloc(source));
    getIt.registerFactory<CropRecommendationsBloc>(
      () => CropRecommendationsBloc(source),
    );
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    bool dark = true,
    String initialRoute = '/',
    List<GoRoute>? routes,
  }) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: initialRoute,
      routes: routes ??
          [
            GoRoute(
              path: '/',
              builder: (_, _) => home,
            ),
          ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: dark
            ? AppTheme.dark(Flavor.development)
            : AppTheme.light(Flavor.development),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CropsListScreen', () {
    testWidgets('renders crop list and filter chips in dark theme',
        (tester) async {
      when(
        () => source.getCrops(
          search: any(named: 'search'),
          type: any(named: 'type'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async => Paged(items: [_crop], page: 1, lastPage: 1),
      );

      await pump(tester, const CropsListScreen());

      expect(find.text('Crops'), findsOneWidget);
      expect(find.text('Ginger'), findsOneWidget);
      expect(find.text('Zingiber officinale'), findsOneWidget);
      expect(find.text('Spices'), findsWidgets);
      expect(find.text('Crop Recommendations'), findsOneWidget);
    });

    testWidgets('renders empty view when no crops exist', (tester) async {
      when(
        () => source.getCrops(
          search: any(named: 'search'),
          type: any(named: 'type'),
          page: any(named: 'page'),
        ),
      ).thenAnswer(
        (_) async => const Paged(items: []),
      );

      await pump(tester, const CropsListScreen());

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No crops found'), findsOneWidget);
    });
  });

  group('CropDetailScreen', () {
    testWidgets('renders crop details, overview and advisory tab', (tester) async {
      when(() => source.getCrop('ginger')).thenAnswer((_) async => _crop);
      when(
        () => source.getCropAdvisory('ginger', districtId: any(named: 'districtId')),
      ).thenAnswer((_) async => _advisory);
      when(
        () => source.getCropCalendar('ginger', districtId: any(named: 'districtId')),
      ).thenAnswer((_) async => null);
      when(() => source.getCropFertilizers('ginger')).thenAnswer(
        (_) async => CropFertilizersModel(
          crop: _crop,
          fertilizers: _advisory.fertilizers!,
        ),
      );
      when(() => source.getCropPrices('ginger', page: 1)).thenAnswer(
        (_) async => const Paged(items: []),
      );

      await pump(tester, const CropDetailScreen(cropSlug: 'ginger'));

      expect(find.text('Ginger'), findsWidgets);
      expect(find.text('Zingiber officinale'), findsOneWidget);
      expect(find.text('Advisory'), findsOneWidget);
      expect(find.text('Fertilizers'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Varieties'), findsOneWidget);
      expect(find.text('Prices'), findsOneWidget);
    });
  });

  group('CropRecommendationsScreen', () {
    testWidgets('renders input form and loads recommendations on submit',
        (tester) async {
      when(
        () => source.getRecommendations(
          districtId: any(named: 'districtId'),
          sowingMonth: any(named: 'sowingMonth'),
          areaHa: any(named: 'areaHa'),
        ),
      ).thenAnswer((_) async => _recommendationResult);

      await pump(tester, const CropRecommendationsScreen());

      expect(find.text('Crop Recommendations'), findsOneWidget);
      expect(find.text('Recommendation Parameters'), findsOneWidget);
      expect(find.text('Get Recommendations'), findsOneWidget);

      await tester.tap(find.text('Get Recommendations'));
      await tester.pumpAndSettle();

      expect(find.text('Ginger'), findsOneWidget);
      expect(find.text('95% Suitability'), findsOneWidget);
    });
  });
}
