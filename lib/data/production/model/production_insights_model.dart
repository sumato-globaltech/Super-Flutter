/// ProductionInsightsModel as returned by the API.
class ProductionInsightsModel {
  String? financialYear;
  int? month;
  String? monthName;
  String? totalTonnes;
  List<ByCropModel>? byCrop;
  List<ByMonthModel>? byMonth;

  ProductionInsightsModel({
    this.financialYear,
    this.month,
    this.monthName,
    this.totalTonnes,
    this.byCrop,
    this.byMonth,
  });

  ProductionInsightsModel.fromJson(Map<String, dynamic> json) {
    financialYear = json['financial_year'];
    month = json['month'];
    monthName = json['month_name'];
    totalTonnes = json['total_tonnes'];
    if (json['by_crop'] != null) {
      byCrop = <ByCropModel>[];
      json['by_crop'].forEach((v) {
        byCrop!.add(ByCropModel.fromJson(v));
      });
    }
    if (json['by_month'] != null) {
      byMonth = <ByMonthModel>[];
      json['by_month'].forEach((v) {
        byMonth!.add(ByMonthModel.fromJson(v));
      });
    }
  }

  // sf:custom:begin ProductionInsightsModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['financial_year'] = financialYear;
    data['month'] = month;
    data['month_name'] = monthName;
    data['total_tonnes'] = totalTonnes;
    if (byCrop != null) {
      data['by_crop'] = byCrop!.map((v) => v.toJson()).toList();
    }
    if (byMonth != null) {
      data['by_month'] = byMonth!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ByCropModel {
  String? cropId;
  String? crop;
  int? records;
  int? districts;
  String? tonnes;

  ByCropModel({
    this.cropId,
    this.crop,
    this.records,
    this.districts,
    this.tonnes,
  });

  ByCropModel.fromJson(Map<String, dynamic> json) {
    cropId = json['crop_id'];
    crop = json['crop'];
    records = json['records'];
    districts = json['districts'];
    tonnes = json['tonnes'];
  }

  // sf:custom:begin ByCropModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['crop_id'] = cropId;
    data['crop'] = crop;
    data['records'] = records;
    data['districts'] = districts;
    data['tonnes'] = tonnes;
    return data;
  }
}

class ByMonthModel {
  int? month;
  String? name;
  String? tonnes;

  ByMonthModel({this.month, this.name, this.tonnes});

  ByMonthModel.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    name = json['name'];
    tonnes = json['tonnes'];
  }

  // sf:custom:begin ByMonthModel
  // Add getters and helpers here. SF preserves this region when it
  // regenerates the model.
  // sf:custom:end

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['month'] = month;
    data['name'] = name;
    data['tonnes'] = tonnes;
    return data;
  }
}
