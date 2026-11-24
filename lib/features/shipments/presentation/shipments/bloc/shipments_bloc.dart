import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

import 'shipments_event.dart';
import 'shipments_state.dart';

@injectable
class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  ShipmentsBloc(this._shipmentsRemoteDataSource)
    : super(const ShipmentsState()) {
    on<ShipmentsStarted>(_onStarted, transformer: restartable());
    on<ShipmentsMoreRequested>(_onMoreRequested, transformer: droppable());
  }

  final ShipmentsRemoteDataSource _shipmentsRemoteDataSource;

  Future<Paged<ShipmentModel>> _page(
    ShipmentParty party, {
    required bool open,
    required int page,
  }) => switch (party) {
    ShipmentParty.vendor => _shipmentsRemoteDataSource.getVendorShipments(
      open: open ? 1 : 0,
      page: page,
      perPage: Paged.defaultPerPage,
    ),
    ShipmentParty.driver => _shipmentsRemoteDataSource.getDriverShipments(
      open: open ? 1 : 0,
      page: page,
      perPage: Paged.defaultPerPage,
    ),
    ShipmentParty.farmer => _shipmentsRemoteDataSource.getShipments(
      open: open ? 1 : 0,
      page: page,
      perPage: Paged.defaultPerPage,
    ),
  };

  Future<void> _onStarted(
    ShipmentsStarted event,
    Emitter<ShipmentsState> emit,
  ) async {
    final open = event.open ?? state.open;
    final party = event.party ?? state.party;
    emit(
      state.copyWith(
        status: ShipmentsStatus.loading,
        open: open,
        party: party,
        clearShipments: open != state.open,
      ),
    );
    try {
      final shipments = await _page(party, open: open, page: 1);
      emit(
        state.copyWith(
          status: ShipmentsStatus.success,
          shipments: shipments,
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ShipmentsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShipmentsStatus.failure));
    }
  }

  Future<void> _onMoreRequested(
    ShipmentsMoreRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    final current = state.shipments;
    final page = current?.nextPage;
    if (current == null ||
        page == null ||
        state.loadingMore ||
        state.status == ShipmentsStatus.loading) {
      return;
    }
    emit(state.copyWith(loadingMore: true));
    try {
      final next = await _page(state.party, open: state.open, page: page);
      // A refresh that finished meanwhile has the newer list.
      if (state.shipments != current) return;
      emit(
        state.copyWith(
          status: ShipmentsStatus.success,
          shipments: current.append(next),
          loadingMore: false,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ShipmentsStatus.failure,
          loadingMore: false,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShipmentsStatus.failure, loadingMore: false));
    }
  }
}
