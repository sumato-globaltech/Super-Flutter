import 'package:equatable/equatable.dart';
import 'package:super_flutter/data/farm/model/farm_model.dart';

enum FarmsListStatus { initial, loading, success, failure }

class FarmsState extends Equatable {
  final FarmsListStatus status;
  final List<FarmModel> items;
  final String statusFilter; // 'active' or 'archived'
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String? errorMessage;

  const FarmsState({
    this.status = FarmsListStatus.initial,
    this.items = const [],
    this.statusFilter = 'active',
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.errorMessage,
  });

  FarmsState copyWith({
    FarmsListStatus? status,
    List<FarmModel>? items,
    String? statusFilter,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? errorMessage,
  }) {
    return FarmsState(
      status: status ?? this.status,
      items: items ?? this.items,
      statusFilter: statusFilter ?? this.statusFilter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    statusFilter,
    page,
    hasMore,
    loadingMore,
    errorMessage,
  ];
}
