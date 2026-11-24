import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/crops/model/crop_model.dart';
import 'package:super_flutter/data/crops/sources/remote/crop_remote_data_source.dart';
import 'package:super_flutter/data/production/sources/remote/production_remote_data_source.dart';

import 'production_event.dart';
import 'production_state.dart';

@injectable
class ProductionBloc extends Bloc<ProductionEvent, ProductionState> {
  ProductionBloc(this._productionRemoteDataSource, this._cropRemoteDataSource)
    : super(const ProductionState()) {
    on<ProductionStarted>(_onStarted, transformer: restartable());
  }

  final ProductionRemoteDataSource _productionRemoteDataSource;
  final CropRemoteDataSource _cropRemoteDataSource;

  /// The filter of the insights on screen, kept when a new one fails.
  ProductionFilter _shown = (month: null, crop: null);

  Future<List<CropModel>> _crops() async {
    if (state.crops.isNotEmpty) return state.crops;
    try {
      return (await _cropRemoteDataSource.getCrops(perPage: 100)).items;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _onStarted(
    ProductionStarted event,
    Emitter<ProductionState> emit,
  ) async {
    final filter = event.filter ?? state.filter;
    emit(state.copyWith(status: ProductionStatus.loading, filter: filter));
    try {
      final (productionInsights, crops) = await (
        _productionRemoteDataSource.getProduction(
          month: filter.month,
          crop: filter.crop,
        ),
        _crops(),
      ).wait;
      _shown = filter;
      emit(
        state.copyWith(
          status: ProductionStatus.success,
          productionInsights: productionInsights,
          crops: crops,
        ),
      );
    } on ParallelWaitError catch (e) {
      final error = (e.errors as (AsyncError?, AsyncError?)).$1?.error;
      emit(
        state.copyWith(
          status: ProductionStatus.failure,
          errorMessage: error is AppException ? error.message : null,
          filter: _shown,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ProductionStatus.failure, filter: _shown));
    }
  }
}
