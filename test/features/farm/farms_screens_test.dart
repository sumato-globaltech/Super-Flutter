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
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/data/farm/sources/remote/farm_remote_data_source.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/bloc/farm_detail_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farm_detail/screen/farm_detail_screen.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/bloc/farm_form_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farm_form/screen/farm_form_screen.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/bloc/farms_bloc.dart';
import 'package:super_flutter/features/farm/presentation/farms_list/screen/farms_list_screen.dart';

class _MockFarmSource extends Mock implements FarmRemoteDataSource {}

final _farm = const FarmModel(
  id: 'f1',
  code: 'FARM-001',
  name: 'Green Hills Farm',
  areaHa: 2.5,
  district: FarmDistrictModel(id: 'd1', name: 'Kohima'),
  village: 'Jakhama',
  isActive: true,
);

final _crop = const FarmCropModel(
  id: 'fc1',
  crop: FarmCropRefModel(id: 'c1', name: 'Ginger'),
  season: ValueLabelModel(value: 'kharif', label: 'Kharif'),
  status: ValueLabelModel(value: 'growing', label: 'Growing'),
  areaHa: 1.2,
);

final _tx = const FarmTransactionModel(
  id: 't1',
  type: ValueLabelModel(value: 'income', label: 'Income'),
  category: FarmCategoryModel(id: 'cat1', name: 'Crop Sale'),
  amount: 25000.0,
  occurredOn: '2026-11-01',
);

final _summary = const FarmTransactionSummaryModel(
  totals: LedgerTotalModel(income: 25000.0, expense: 5000.0, net: 20000.0),
);

void main() {
  late _MockFarmSource source;

  setUp(() async {
    source = _MockFarmSource();
    await getIt.reset();
    getIt.registerLazySingleton<FarmRemoteDataSource>(() => source);
    getIt.registerFactory<FarmsBloc>(() => FarmsBloc(source));
    getIt.registerFactory<FarmFormBloc>(() => FarmFormBloc(source));
    getIt.registerFactory<FarmDetailBloc>(() => FarmDetailBloc(source));
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

  group('FarmsListScreen', () {
    testWidgets('renders active farms and segmented control', (tester) async {
      when(
        () => source.getFarms(status: 'active', page: 1),
      ).thenAnswer(
        (_) async => Paged(items: [_farm], page: 1, lastPage: 1),
      );

      await pump(tester, const FarmsListScreen());

      expect(find.text('Farms'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Green Hills Farm'), findsOneWidget);
      expect(find.text('2.5 ha'), findsOneWidget);
      expect(find.text('FARM-001'), findsOneWidget);
    });

    testWidgets('renders empty view when no farms exist', (tester) async {
      when(
        () => source.getFarms(status: 'active', page: 1),
      ).thenAnswer(
        (_) async => const Paged(items: []),
      );

      await pump(tester, const FarmsListScreen());

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No farms found'), findsOneWidget);
    });
  });

  group('FarmFormScreen', () {
    testWidgets('renders form fields for new farm', (tester) async {
      await pump(tester, const FarmFormScreen());

      expect(find.text('Add Farm'), findsOneWidget);
      expect(find.text('Farm Name *'), findsOneWidget);
      expect(find.text('Area (ha) *'), findsOneWidget);
      expect(find.text('Create Farm'), findsOneWidget);
    });

    testWidgets('renders form fields with initialFarm for edit', (tester) async {
      await pump(tester, FarmFormScreen(initialFarm: _farm));

      expect(find.text('Edit Farm'), findsOneWidget);
      expect(find.text('Green Hills Farm'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('Update Farm'), findsOneWidget);
    });
  });

  group('FarmDetailScreen', () {
    testWidgets('renders farm overview card and crops tab', (tester) async {
      when(() => source.getFarm('f1')).thenAnswer((_) async => _farm);
      when(() => source.getFarmCrops('f1')).thenAnswer((_) async => [_crop]);
      when(() => source.getTransactions('f1', page: 1))
          .thenAnswer((_) async => Paged(items: [_tx]));
      when(() => source.getTransactionSummary('f1'))
          .thenAnswer((_) async => _summary);
      when(() => source.getPhotos('f1')).thenAnswer((_) async => const []);

      await pump(tester, const FarmDetailScreen(farmId: 'f1'));

      expect(find.text('Green Hills Farm'), findsWidgets);
      expect(find.text('FARM-001'), findsOneWidget);
      expect(find.text('2.5 ha'), findsOneWidget);
      expect(find.text('Crops (1)'), findsOneWidget);
      expect(find.text('Transactions (1)'), findsOneWidget);
      expect(find.text('Photos (0)'), findsOneWidget);
      expect(find.text('Ginger'), findsOneWidget);
      expect(find.text('Kharif'), findsOneWidget);
    });
  });
}
