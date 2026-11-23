import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_advisory_model.dart';
import 'package:super_flutter/data/crops/model/crop_calendar_model.dart';
import 'package:super_flutter/data/crops/model/crop_fertilizers_model.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/market/model/market_price_model.dart';

enum CropDetailStatus { initial, loading, success, failure }

class CropDetailState extends Equatable {
  final CropDetailStatus status;
  final String slug;
  final String? districtId;
  final CropModel? crop;
  final CropAdvisoryModel? advisory;
  final CropCalendarModel? calendar;
  final CropFertilizersModel? fertilizers;
  final List<MarketPriceModel> prices;
  final int pricesPage;
  final bool pricesHasMore;
  final bool loadingMorePrices;
  final int selectedTab;
  final String? errorMessage;

  const CropDetailState({
    this.status = CropDetailStatus.initial,
    this.slug = '',
    this.districtId,
    this.crop,
    this.advisory,
    this.calendar,
    this.fertilizers,
    this.prices = const [],
    this.pricesPage = 1,
    this.pricesHasMore = false,
    this.loadingMorePrices = false,
    this.selectedTab = 0,
    this.errorMessage,
  });

  CropDetailState copyWith({
    CropDetailStatus? status,
    String? slug,
    String? districtId,
    CropModel? crop,
    CropAdvisoryModel? advisory,
    CropCalendarModel? calendar,
    CropFertilizersModel? fertilizers,
    List<MarketPriceModel>? prices,
    int? pricesPage,
    bool? pricesHasMore,
    bool? loadingMorePrices,
    int? selectedTab,
    String? errorMessage,
  }) {
    return CropDetailState(
      status: status ?? this.status,
      slug: slug ?? this.slug,
      districtId: districtId ?? this.districtId,
      crop: crop ?? this.crop,
      advisory: advisory ?? this.advisory,
      calendar: calendar ?? this.calendar,
      fertilizers: fertilizers ?? this.fertilizers,
      prices: prices ?? this.prices,
      pricesPage: pricesPage ?? this.pricesPage,
      pricesHasMore: pricesHasMore ?? this.pricesHasMore,
      loadingMorePrices: loadingMorePrices ?? this.loadingMorePrices,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        slug,
        districtId,
        crop,
        advisory,
        calendar,
        fertilizers,
        prices,
        pricesPage,
        pricesHasMore,
        loadingMorePrices,
        selectedTab,
        errorMessage,
      ];
}
