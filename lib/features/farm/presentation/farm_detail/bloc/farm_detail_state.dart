import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/farm_crop_model.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';
import 'package:super_flutter/data/farm/model/farm_photo_model.dart';
import 'package:super_flutter/data/farm/model/farm_transaction_model.dart';

enum FarmDetailStatus { initial, loading, success, failure }

class FarmDetailState extends Equatable {
  final FarmDetailStatus status;
  final String farmId;
  final FarmModel? farm;
  final List<FarmCropModel> crops;
  final List<FarmTransactionModel> transactions;
  final FarmTransactionSummaryModel? summary;
  final List<FarmPhotoModel> photos;
  final int selectedTab;
  final bool isActionLoading;
  final bool isDeleted;
  final String? errorMessage;

  const FarmDetailState({
    this.status = FarmDetailStatus.initial,
    this.farmId = '',
    this.farm,
    this.crops = const [],
    this.transactions = const [],
    this.summary,
    this.photos = const [],
    this.selectedTab = 0,
    this.isActionLoading = false,
    this.isDeleted = false,
    this.errorMessage,
  });

  FarmDetailState copyWith({
    FarmDetailStatus? status,
    String? farmId,
    FarmModel? farm,
    List<FarmCropModel>? crops,
    List<FarmTransactionModel>? transactions,
    FarmTransactionSummaryModel? summary,
    List<FarmPhotoModel>? photos,
    int? selectedTab,
    bool? isActionLoading,
    bool? isDeleted,
    String? errorMessage,
  }) {
    return FarmDetailState(
      status: status ?? this.status,
      farmId: farmId ?? this.farmId,
      farm: farm ?? this.farm,
      crops: crops ?? this.crops,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
      photos: photos ?? this.photos,
      selectedTab: selectedTab ?? this.selectedTab,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: errorMessage ?? this.errorMessage,
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
        selectedTab,
        isActionLoading,
        isDeleted,
        errorMessage,
      ];
}
