import 'package:equatable/equatable.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/model/scheme_model.dart';

enum SchemesStatus { initial, loading, success, failure }

class SchemesState extends Equatable {
  const SchemesState({
    this.status = SchemesStatus.initial,
    this.schemes,
    this.loadingMore = false,
    this.errorMessage,
    this.officer = false,
  });

  final SchemesStatus status;
  final Paged<SchemeModel>? schemes;
  final bool loadingMore;
  final String? errorMessage;
  final bool officer;

  SchemesState copyWith({
    SchemesStatus? status,
    Paged<SchemeModel>? schemes,
    bool? loadingMore,
    String? errorMessage,
    bool? officer,
  }) {
    return SchemesState(
      status: status ?? this.status,
      schemes: schemes ?? this.schemes,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: errorMessage,
      officer: officer ?? this.officer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    schemes,
    loadingMore,
    errorMessage,
    officer,
  ];
}
