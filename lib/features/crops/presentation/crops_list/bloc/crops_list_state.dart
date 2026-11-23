import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';

enum CropsListStatus { initial, loading, success, failure }

class CropsListState extends Equatable {
  final CropsListStatus status;
  final List<CropModel> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String search;
  final String? selectedType;
  final String? errorMessage;

  const CropsListState({
    this.status = CropsListStatus.initial,
    this.items = const [],
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.search = '',
    this.selectedType,
    this.errorMessage,
  });

  CropsListState copyWith({
    CropsListStatus? status,
    List<CropModel>? items,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? search,
    String? Function()? selectedType,
    String? errorMessage,
  }) {
    return CropsListState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      search: search ?? this.search,
      selectedType:
          selectedType != null ? selectedType() : this.selectedType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        page,
        hasMore,
        loadingMore,
        search,
        selectedType,
        errorMessage,
      ];
}
