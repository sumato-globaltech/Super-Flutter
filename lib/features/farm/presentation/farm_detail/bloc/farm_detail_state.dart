import 'package:super_flutter/data/farm/model/transaction_category_model.dart';
import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';
import 'package:super_flutter/data/iot/model/device_model.dart';
import 'package:super_flutter/data/iot/model/soil_sensor_account_model.dart';

enum FarmDetailStatus { initial, loading, success, failure }

class FarmDetailState extends Equatable {
  final FarmDetailStatus status;
  final String farmId;
  final FarmModel? farm;
  final List<FarmCropModel> crops;
  final List<FarmTransactionModel> transactions;
  final FarmTransactionSummaryModel? summary;
  final List<FarmPhotoModel> photos;
  final List<DeviceModel> devices;
  final SoilSensorAccountModel? soilSensorAccount;
  final List<TransactionCategoryModel> transactionCategories;
  final int selectedTab;
  final bool isActionLoading;
  final bool isSyncingDevices;
  final bool isDeleted;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const FarmDetailState({
    this.status = FarmDetailStatus.initial,
    this.farmId = '',
    this.farm,
    this.crops = const [],
    this.transactions = const [],
    this.summary,
    this.photos = const [],
    this.devices = const [],
    this.soilSensorAccount,
    this.transactionCategories = const [],
    this.selectedTab = 0,
    this.isActionLoading = false,
    this.isSyncingDevices = false,
    this.isDeleted = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  FarmDetailState copyWith({
    FarmDetailStatus? status,
    String? farmId,
    FarmModel? farm,
    List<FarmCropModel>? crops,
    List<FarmTransactionModel>? transactions,
    FarmTransactionSummaryModel? summary,
    List<FarmPhotoModel>? photos,
    List<DeviceModel>? devices,
    SoilSensorAccountModel? soilSensorAccount,
    bool clearSoilSensorAccount = false,
    List<TransactionCategoryModel>? transactionCategories,
    int? selectedTab,
    bool? isActionLoading,
    bool? isSyncingDevices,
    bool? isDeleted,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return FarmDetailState(
      status: status ?? this.status,
      farmId: farmId ?? this.farmId,
      farm: farm ?? this.farm,
      crops: crops ?? this.crops,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      photos: photos ?? this.photos,
      devices: devices ?? this.devices,
      soilSensorAccount: clearSoilSensorAccount
          ? null
          : (soilSensorAccount ?? this.soilSensorAccount),
      transactionCategories:
          transactionCategories ?? this.transactionCategories,
      selectedTab: selectedTab ?? this.selectedTab,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isSyncingDevices: isSyncingDevices ?? this.isSyncingDevices,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: errorMessage ?? this.errorMessage,
      actionSuccessMessage: actionSuccessMessage ?? this.actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    farmId,
    farm,
    crops,
    transactions,
    summary,
    photos,
    devices,
    soilSensorAccount,
    transactionCategories,
    selectedTab,
    isActionLoading,
    isSyncingDevices,
    isDeleted,
    errorMessage,
    actionSuccessMessage,
  ];
}
