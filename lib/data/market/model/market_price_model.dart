import 'market_model.dart';
import 'market_summary_model.dart';

class MarketPriceModel {
  String? id;
  MarketModel? market;
  CropModel? crop;
  String? priceDate;
  num? minPrice;
  num? modalPrice;
  num? maxPrice;
  UnitModel? unit;
  double? modalPricePerQuintal;
  String? source;

  MarketPriceModel({
    this.id,
    this.market,
    this.crop,
    this.priceDate,
    this.minPrice,
    this.modalPrice,
    this.maxPrice,
    this.unit,
    this.modalPricePerQuintal,
    this.source,
  });

  MarketPriceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    market = json['market'] != null
        ? MarketModel.fromJson(Map<String, dynamic>.from(json['market']))
        : null;
    crop = json['crop'] != null
        ? CropModel.fromJson(Map<String, dynamic>.from(json['crop']))
        : null;
    priceDate = json['price_date'];
    minPrice = json['min_price'] is num
        ? json['min_price']
        : num.tryParse('${json['min_price']}');
    modalPrice = json['modal_price'] is num
        ? json['modal_price']
        : num.tryParse('${json['modal_price']}');
    maxPrice = json['max_price'] is num
        ? json['max_price']
        : num.tryParse('${json['max_price']}');
    unit = json['unit'] != null
        ? UnitModel.fromJson(Map<String, dynamic>.from(json['unit']))
        : null;
    modalPricePerQuintal = json['modal_price_per_quintal'] != null
        ? double.tryParse(json['modal_price_per_quintal'].toString())
        : null;
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (market != null) {
      data['market'] = market!.toJson();
    }
    if (crop != null) {
      data['crop'] = crop!.toJson();
    }
    data['price_date'] = priceDate;
    data['min_price'] = minPrice;
    data['modal_price'] = modalPrice;
    data['max_price'] = maxPrice;
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    data['modal_price_per_quintal'] = modalPricePerQuintal;
    data['source'] = source;
    return data;
  }
}

class UnitModel {
  String? code;
  String? name;

  UnitModel({this.code, this.name});

  UnitModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}
