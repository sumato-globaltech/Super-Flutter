import 'package:equatable/equatable.dart';

class MarketSummaryModel extends Equatable {
  final int? markets;
  final int? marketsReportingToday;
  final int? cropsTracked;
  final String? latestPriceDate;
  final int? recentDays;
  final String? priceUnit;
  final List<CropSummaryModel>? crops;

  const MarketSummaryModel({
    this.markets,
    this.marketsReportingToday,
    this.cropsTracked,
    this.latestPriceDate,
    this.recentDays,
    this.priceUnit,
    this.crops,
  });

  MarketSummaryModel.fromJson(Map<String, dynamic> json)
      : markets = json['markets'] is int
            ? json['markets']
            : int.tryParse('${json['markets']}'),
        marketsReportingToday = json['markets_reporting_today'] is int
            ? json['markets_reporting_today']
            : int.tryParse('${json['markets_reporting_today']}'),
        cropsTracked = json['crops_tracked'] is int
            ? json['crops_tracked']
            : int.tryParse('${json['crops_tracked']}'),
        latestPriceDate = json['latest_price_date'],
        recentDays = json['recent_days'] is int
            ? json['recent_days']
            : int.tryParse('${json['recent_days']}'),
        priceUnit = json['price_unit'],
        crops = json['crops'] != null && json['crops'] is List
            ? (json['crops'] as List)
                .whereType<Map>()
                .map((e) =>
                    CropSummaryModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['markets'] = markets;
    data['markets_reporting_today'] = marketsReportingToday;
    data['crops_tracked'] = cropsTracked;
    data['latest_price_date'] = latestPriceDate;
    data['recent_days'] = recentDays;
    data['price_unit'] = priceUnit;
    if (crops != null) {
      data['crops'] = crops!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [
    markets,
    marketsReportingToday,
    cropsTracked,
    latestPriceDate,
    recentDays,
    priceUnit,
    crops,
  ];
}

class CropSummaryModel extends Equatable {
  final CropModel? crop;
  final int? markets;
  final String? latestPriceDate;
  final String? lowestPrice;
  final String? medianPrice;
  final String? highestPrice;

  const CropSummaryModel({
    this.crop,
    this.markets,
    this.latestPriceDate,
    this.lowestPrice,
    this.medianPrice,
    this.highestPrice,
  });

  CropSummaryModel.fromJson(Map<String, dynamic> json)
      : crop = json['crop'] != null
            ? CropModel.fromJson(Map<String, dynamic>.from(json['crop']))
            : null,
        markets = json['markets'] is int
            ? json['markets']
            : int.tryParse('${json['markets']}'),
        latestPriceDate = json['latest_price_date'],
        lowestPrice = json['lowest_price']?.toString(),
        medianPrice = json['median_price']?.toString(),
        highestPrice = json['highest_price']?.toString();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (crop != null) {
      data['crop'] = crop!.toJson();
    }
    data['markets'] = markets;
    data['latest_price_date'] = latestPriceDate;
    data['lowest_price'] = lowestPrice;
    data['median_price'] = medianPrice;
    data['highest_price'] = highestPrice;
    return data;
  }

  @override
  List<Object?> get props => [
    crop,
    markets,
    latestPriceDate,
    lowestPrice,
    medianPrice,
    highestPrice,
  ];
}

class CropModel extends Equatable {
  final String? id;
  final String? name;
  final String? slug;

  const CropModel({this.id, this.name, this.slug});

  CropModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        slug = json['slug'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }

  @override
  List<Object?> get props => [id, name, slug];
}
