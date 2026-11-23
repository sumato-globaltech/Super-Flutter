import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/app/config/flavor.dart';
import 'package:super_flutter/core/di/injection.dart';
import 'package:super_flutter/core/error/exceptions/unknown_exception.dart';
import 'package:super_flutter/core/localization/app_localizations.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/core/ui/theme/app_theme.dart';
import 'package:super_flutter/core/ui/widgets/app_empty_view.dart';
import 'package:super_flutter/core/ui/widgets/app_error_view.dart';
import 'package:super_flutter/data/market/model/market_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';
import 'package:super_flutter/data/market/model/market_summary_model.dart';
import 'package:super_flutter/data/market/sources/remote/market_remote_data_source.dart';
import 'package:super_flutter/domain/auth/entities/user.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_cubit.dart';
import 'package:super_flutter/features/auth/session/bloc/auth_state.dart';
import 'package:super_flutter/features/market/presentation/market/bloc/market_bloc.dart';
import 'package:super_flutter/features/market/presentation/market/screen/market_screen.dart';
import 'package:super_flutter/features/market/presentation/market_prices/bloc/market_prices_bloc.dart';
import 'package:super_flutter/features/market/presentation/market_prices/screen/market_prices_screen.dart';

class _Source extends Mock implements MarketRemoteDataSource {}

class _AuthCubit extends MockCubit<AuthState> implements AuthCubit {}

final _summary = MarketSummaryModel(
  markets: 4,
  marketsReportingToday: 2,
  cropsTracked: 5,
  priceUnit: 'qtl',
  crops: [
    CropSummaryModel(
      crop: CropModel(id: 'c1', name: 'Rice', slug: 'rice'),
      markets: 2,
      medianPrice: '2200.00',
    ),
  ],
);

final _markets = Paged(
  items: [
    MarketModel(
      id: 'm1',
      name: 'Kohima Town',
      district: DistrictModel(id: 'd1', name: 'Kohima'),
      type: MarketTypeModel(value: 'retail', label: 'Retail'),
      address: 'Main Town Road',
      latitude: 25.67,
      longitude: 94.11,
      facilities: ['Cold storage', 'Parking'],
    ),
    MarketModel(
      id: 'm2',
      name: 'Dimapur Mandi',
      district: DistrictModel(id: 'd2', name: 'Dimapur'),
      type: MarketTypeModel(value: 'wholesale', label: 'Wholesale'),
    ),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 2,
);

final _prices = Paged(
  items: [
    MarketPriceModel(
      id: 'p1',
      crop: CropModel(id: 'c1', name: 'Rice'),
      priceDate: '2026-11-16',
      modalPrice: 2200,
      minPrice: 2000,
      maxPrice: 2400,
      unit: UnitModel(code: 'qtl', name: 'Quintal'),
    ),
  ],
  page: 1,
  lastPage: 1,
  perPage: 20,
  total: 1,
);

void main() {
  late _Source source;
  late _AuthCubit authCubit;

  setUp(() async {
    source = _Source();
    authCubit = _AuthCubit();
    await getIt.reset();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    bool dark = true,
    bool isAuthenticated = false,
    String initialRoute = '/',
    List<GoRoute>? routes,
  }) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    when(() => authCubit.state).thenReturn(
      AuthState(
        status: isAuthenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: isAuthenticated
            ? const User(
                id: 'u1',
                name: 'Ramesh',
                email: 'test@example.com',
                role: UserRole(value: 'farmer', label: 'Farmer'),
                permissions: {},
              )
            : null,
      ),
    );

    final router = GoRouter(
      initialLocation: initialRoute,
      routes: routes ?? [
        GoRoute(
          path: '/',
          builder: (_, _) => home,
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: MaterialApp.router(
          theme: dark
              ? AppTheme.dark(Flavor.development)
              : AppTheme.light(Flavor.development),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ─── Market Screen Tests ───

  group('MarketScreen', () {
    testWidgets('shows summary card and market list', (tester) async {
      when(() => source.getSummary()).thenAnswer((_) async => _summary);
      when(
        () => source.getMarkets(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _markets);

      getIt.registerFactory<MarketBloc>(() => MarketBloc(source));

      await pump(tester, const MarketScreen(), dark: true);

      // App bar
      expect(find.text('Market'), findsOneWidget);

      // Summary
      expect(find.text('Price Overview'), findsOneWidget);
      expect(find.text('2 markets reporting today'), findsOneWidget);
      expect(find.text('5 crops tracked'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('₹2200.00 / qtl'), findsOneWidget);

      // Filter
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favourites'), findsOneWidget);

      // Market list
      expect(find.text('Kohima Town'), findsOneWidget);
      expect(find.text('Dimapur Mandi'), findsOneWidget);
      expect(find.text('Kohima · Retail'), findsOneWidget);
      expect(find.text('Dimapur · Wholesale'), findsOneWidget);
    });

    testWidgets('empty list shows empty view', (tester) async {
      when(() => source.getSummary()).thenAnswer(
        (_) async => MarketSummaryModel(markets: 0),
      );
      when(
        () => source.getMarkets(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => const Paged(items: <MarketModel>[]));

      getIt.registerFactory<MarketBloc>(() => MarketBloc(source));

      await pump(tester, const MarketScreen());

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No markets found'), findsOneWidget);
    });

    testWidgets('error state shows retry and reloads', (tester) async {
      when(() => source.getSummary()).thenThrow(const UnknownException('Offline'));
      when(
        () => source.getMarkets(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenThrow(const UnknownException('Offline'));

      getIt.registerFactory<MarketBloc>(() => MarketBloc(source));

      await pump(tester, const MarketScreen());

      expect(find.byType(AppErrorView), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);

      // When retried with success
      when(() => source.getSummary()).thenAnswer((_) async => _summary);
      when(
        () => source.getMarkets(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _markets);

      tester.widget<AppErrorView>(find.byType(AppErrorView)).onRetry!();
      await tester.pumpAndSettle();
      expect(find.text('Kohima Town'), findsOneWidget);
    });
  });

  // ─── Market Prices Screen Tests ───

  group('MarketPricesScreen', () {
    testWidgets('shows market details card and price history', (tester) async {
      when(
        () => source.getPriceHistory(
          marketId: 'm1',
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => _prices);

      getIt.registerFactory<MarketPricesBloc>(() => MarketPricesBloc(source));

      await pump(
        tester,
        MarketPricesScreen(
          marketId: 'm1',
          market: _markets.items.first,
        ),
        dark: true,
      );

      // App bar
      expect(find.text('Kohima Town'), findsWidgets);

      // Details card
      expect(find.text('Kohima'), findsOneWidget);
      expect(find.text('Retail'), findsOneWidget);
      expect(find.text('Main Town Road'), findsOneWidget);
      expect(find.text('Cold storage, Parking'), findsOneWidget);

      // Price history
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Nov 16, 2026'), findsOneWidget);
      expect(find.text('₹2200 / qtl'), findsOneWidget);
      expect(find.text('Min ₹2000 · Max ₹2400'), findsOneWidget);
    });

    testWidgets('empty prices shows empty view', (tester) async {
      when(
        () => source.getPriceHistory(
          marketId: 'm1',
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => const Paged(items: <MarketPriceModel>[]));

      getIt.registerFactory<MarketPricesBloc>(() => MarketPricesBloc(source));

      await pump(
        tester,
        const MarketPricesScreen(marketId: 'm1'),
      );

      expect(find.byType(AppEmptyView), findsOneWidget);
      expect(find.text('No price records'), findsOneWidget);
    });
  });
}
