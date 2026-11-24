import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart';

import 'request_shipment_event.dart';
import 'request_shipment_state.dart';

@injectable
class RequestShipmentBloc
    extends Bloc<RequestShipmentEvent, RequestShipmentState> {
  RequestShipmentBloc(this._shipmentsRemoteDataSource)
    : super(const RequestShipmentState()) {
    on<RequestShipmentStarted>(_onStarted, transformer: restartable());
    on<RequestShipmentFieldErrorCleared>(_onFieldErrorCleared);
    on<RequestShipmentSubmitted>(_onSubmitted, transformer: droppable());
  }

  final ShipmentsRemoteDataSource _shipmentsRemoteDataSource;

  Future<void> _onStarted(
    RequestShipmentStarted event,
    Emitter<RequestShipmentState> emit,
  ) async {
    emit(state.copyWith(status: RequestShipmentStatus.loading));
    try {
      final options = await _shipmentsRemoteDataSource.getShipmentOptions();
      emit(
        state.copyWith(status: RequestShipmentStatus.ready, options: options),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: RequestShipmentStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: RequestShipmentStatus.failure));
    }
  }

  void _onFieldErrorCleared(
    RequestShipmentFieldErrorCleared event,
    Emitter<RequestShipmentState> emit,
  ) {
    if (!state.fieldErrors.containsKey(event.field)) return;
    emit(
      state.copyWith(
        fieldErrors: Map.of(state.fieldErrors)..remove(event.field),
      ),
    );
  }

  Future<void> _onSubmitted(
    RequestShipmentSubmitted event,
    Emitter<RequestShipmentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RequestShipmentStatus.submitting,
        fieldErrors: const {},
      ),
    );
    try {
      final ok = await _shipmentsRemoteDataSource.requestShipment(
        vendorId: event.vendorId,
        pickupDistrictId: event.pickupDistrictId,
        pickupAddress: event.pickupAddress,
        preferredPickupOn: event.preferredPickupOn,
        items: event.items,
        notes: event.notes,
      );
      emit(
        state.copyWith(
          status: ok
              ? RequestShipmentStatus.success
              : RequestShipmentStatus.failure,
        ),
      );
    } on ValidationException catch (e) {
      emit(
        state.copyWith(
          status: RequestShipmentStatus.failure,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: RequestShipmentStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: RequestShipmentStatus.failure));
    }
  }
}
