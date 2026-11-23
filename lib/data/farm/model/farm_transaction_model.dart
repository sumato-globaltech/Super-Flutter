import 'package:equatable/equatable.dart';
import 'farm_model.dart';

class FarmTransactionModel extends Equatable {
  final String? id;
  final String? farmCropId;
  final ValueLabelModel? type;
  final FarmCategoryModel? category;
  final double? amount;
  final String? occurredOn;
  final String? description;

  const FarmTransactionModel({
    this.id,
    this.farmCropId,
    this.type,
    this.category,
    this.amount,
    this.occurredOn,
    this.description,
  });

  bool get isIncome => type?.value == 'income';
  bool get isExpense => type?.value == 'expense';

  factory FarmTransactionModel.fromJson(Map<String, dynamic> json) {
    return FarmTransactionModel(
      id: json['id'] as String?,
      farmCropId: json['farm_crop_id'] as String?,
      type: json['type'] is Map
          ? ValueLabelModel.fromJson(
              Map<String, dynamic>.from(json['type'] as Map),
            )
          : null,
      category: json['category'] is Map
          ? FarmCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse('${json['amount']}'),
      occurredOn: json['occurred_on'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_crop_id': farmCropId,
      if (type != null) 'type': type!.toJson(),
      if (category != null) 'category': category!.toJson(),
      'amount': amount,
      'occurred_on': occurredOn,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        farmCropId,
        type,
        category,
        amount,
        occurredOn,
        description,
      ];
}

class FarmCategoryModel extends Equatable {
  final String? id;
  final String? name;

  const FarmCategoryModel({this.id, this.name});

  factory FarmCategoryModel.fromJson(Map<String, dynamic> json) {
    return FarmCategoryModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class FarmTransactionSummaryModel extends Equatable {
  final LedgerTotalModel? totals;
  final LedgerTotalModel? general;
  final List<CropLedgerTotalModel> crops;

  const FarmTransactionSummaryModel({
    this.totals,
    this.general,
    this.crops = const [],
  });

  factory FarmTransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawCrops = json['crops'];
    final parsedCrops = rawCrops is List
        ? rawCrops
            .whereType<Map>()
            .map((e) => CropLedgerTotalModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <CropLedgerTotalModel>[];

    return FarmTransactionSummaryModel(
      totals: json['totals'] is Map
          ? LedgerTotalModel.fromJson(
              Map<String, dynamic>.from(json['totals'] as Map),
            )
          : null,
      general: json['general'] is Map
          ? LedgerTotalModel.fromJson(
              Map<String, dynamic>.from(json['general'] as Map),
            )
          : null,
      crops: parsedCrops,
    );
  }

  @override
  List<Object?> get props => [totals, general, crops];
}

class LedgerTotalModel extends Equatable {
  final double income;
  final double expense;
  final double net;

  const LedgerTotalModel({
    this.income = 0.0,
    this.expense = 0.0,
    this.net = 0.0,
  });

  factory LedgerTotalModel.fromJson(Map<String, dynamic> json) {
    return LedgerTotalModel(
      income: json['income'] is num
          ? (json['income'] as num).toDouble()
          : (double.tryParse('${json['income']}') ?? 0.0),
      expense: json['expense'] is num
          ? (json['expense'] as num).toDouble()
          : (double.tryParse('${json['expense']}') ?? 0.0),
      net: json['net'] is num
          ? (json['net'] as num).toDouble()
          : (double.tryParse('${json['net']}') ?? 0.0),
    );
  }

  @override
  List<Object?> get props => [income, expense, net];
}

class CropLedgerTotalModel extends Equatable {
  final String? farmCropId;
  final String? crop;
  final String? season;
  final String? financialYear;
  final double income;
  final double expense;
  final double net;

  const CropLedgerTotalModel({
    this.farmCropId,
    this.crop,
    this.season,
    this.financialYear,
    this.income = 0.0,
    this.expense = 0.0,
    this.net = 0.0,
  });

  factory CropLedgerTotalModel.fromJson(Map<String, dynamic> json) {
    return CropLedgerTotalModel(
      farmCropId: json['farm_crop_id'] as String?,
      crop: json['crop'] as String?,
      season: json['season'] as String?,
      financialYear: json['financial_year'] as String?,
      income: json['income'] is num
          ? (json['income'] as num).toDouble()
          : (double.tryParse('${json['income']}') ?? 0.0),
      expense: json['expense'] is num
          ? (json['expense'] as num).toDouble()
          : (double.tryParse('${json['expense']}') ?? 0.0),
      net: json['net'] is num
          ? (json['net'] as num).toDouble()
          : (double.tryParse('${json['net']}') ?? 0.0),
    );
  }

  @override
  List<Object?> get props => [
        farmCropId,
        crop,
        season,
        financialYear,
        income,
        expense,
        net,
      ];
}
