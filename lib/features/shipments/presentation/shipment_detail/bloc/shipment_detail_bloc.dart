import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';

import 'shipment_detail_event.dart';
import 'shipment_detail_state.dart';

@injectable
class ShipmentDetailBloc
    extends Bloc<ShipmentDetailEvent, ShipmentDetailState> {
  ShipmentDetailBloc(this._shipmentsRemoteDataSource)
    : super(const ShipmentDetailState()) {
    on<ShipmentDetailStarted>(_onStarted, transformer: restartable());
    on<ShipmentActionSubmitted>(_onActionSubmitted, transformer: droppable());
    on<ShipmentAssignmentOptionsRequested>(_onAssignmentOptionsRequested);
  }

  final ShipmentsRemoteDataSource _shipmentsRemoteDataSource;

  Future<ShipmentModel?> _load(String shipment, ShipmentParty party) =>
      switch (party) {
        ShipmentParty.vendor => _shipmentsRemoteDataSource.getVendorShipment(
          shipment,
        ),
        _ => _shipmentsRemoteDataSource.getShipment(shipment),
      };

  Future<void> _onStarted(
    ShipmentDetailStarted event,
    Emitter<ShipmentDetailState> emit,
  ) async {
    emit(
      state.copyWith(status: ShipmentDetailStatus.loading, party: event.party),
    );
    try {
      final shipmentDetails = await _load(event.shipment, event.party);
      emit(
        state.copyWith(
          status: ShipmentDetailStatus.success,
          shipmentDetails: shipmentDetails,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: ShipmentDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ShipmentDetailStatus.failure));
    }
  }

  Future<void> _onActionSubmitted(
    ShipmentActionSubmitted event,
    Emitter<ShipmentDetailState> emit,
  ) async {
    final source = _shipmentsRemoteDataSource;
    final id = event.shipment;
    try {
      switch (event.action) {
        case ShipmentAction.cancel:
          await source.cancelShipment(id, reason: event.reason!);
        case ShipmentAction.accept:
          await source.acceptShipment(
            id,
            vehicleId: event.vehicleId!,
            driverId: event.driverId!,
          );
        case ShipmentAction.reject:
          await source.rejectShipment(id, reason: event.reason!);
        case ShipmentAction.reassign:
          await source.updateReassignShipment(
            id,
            vehicleId: event.vehicleId!,
            driverId: event.driverId!,
          );
        case ShipmentAction.receive:
          await source.receiveShipment(id, quantities: event.quantities!);
        case ShipmentAction.reweigh:
          await source.reweighShipmentItem(
            id,
            event.itemId!,
            quantity: event.quantity!,
            reason: event.reason,
          );
      }
      final shipmentDetails = await _load(id, state.party);
      emit(
        state.copyWith(
          status: ShipmentDetailStatus.success,
          shipmentDetails: shipmentDetails,
        ),
      );
      event.completer.complete();
    } catch (e) {
      event.completer.completeError(e);
    }
  }

  Future<void> _onAssignmentOptionsRequested(
    ShipmentAssignmentOptionsRequested event,
    Emitter<ShipmentDetailState> emit,
  ) async {
    try {
      event.completer.complete(
        await _shipmentsRemoteDataSource.getAssignmentOptions(event.shipment),
      );
    } catch (e) {
      event.completer.completeError(e);
    }
  }
}
