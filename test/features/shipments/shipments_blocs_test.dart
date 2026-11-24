import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/shipments/model/assignment_options_model.dart';
import 'package:super_flutter/data/shipments/model/shipment_model.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_party.dart';
import 'package:super_flutter/data/shipments/model/shipment_options_model.dart';
import 'package:super_flutter/data/shipments/sources/remote/shipments_remote_data_source.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_event.dart';
import 'package:super_flutter/features/shipments/presentation/request_shipment/bloc/request_shipment_state.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/shipment_detail/bloc/shipment_detail_event.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_bloc.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_event.dart';
import 'package:super_flutter/features/shipments/presentation/shipments/bloc/shipments_state.dart';

class _MockSource extends Mock implements ShipmentsRemoteDataSource {}

void main() {
  late _MockSource source;
  final active = ShipmentModel(id: 's1', number: 'SHP-000001');
  final done = ShipmentModel(id: 's2', number: 'SHP-000002');

  setUpAll(() => registerFallbackValue(DateTime(2026)));
  setUp(() => source = _MockSource());

  group('ShipmentsBloc', () {
    blocTest<ShipmentsBloc, ShipmentsState>(
      'loads active shipments first, then history with open=0',
      build: () {
        when(
          () => source.getShipments(
            open: 1,
            page: 1,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => Paged(items: [active]));
        when(
          () => source.getShipments(
            open: 0,
            page: 1,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => Paged(items: [done]));
        return ShipmentsBloc(source);
      },
      act: (bloc) async {
        bloc.add(const ShipmentsStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ShipmentsStarted(open: false));
      },
      verify: (bloc) {
        expect(bloc.state.open, isFalse);
        expect(bloc.state.shipments?.items, [done]);
      },
    );

    blocTest<ShipmentsBloc, ShipmentsState>(
      'switching tabs clears the other tab\'s list while loading',
      build: () {
        when(
          () => source.getShipments(
            open: any(named: 'open'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => Paged(items: [active]));
        return ShipmentsBloc(source);
      },
      seed: () => ShipmentsState(
        status: ShipmentsStatus.success,
        shipments: Paged(items: [active]),
      ),
      act: (bloc) => bloc.add(const ShipmentsStarted(open: false)),
      expect: () => [
        const ShipmentsState(status: ShipmentsStatus.loading, open: false),
        isA<ShipmentsState>()
            .having((s) => s.status, 'status', ShipmentsStatus.success)
            .having((s) => s.open, 'open', isFalse),
      ],
    );
  });

  group('RequestShipmentBloc', () {
    RequestShipmentSubmitted submitted() => RequestShipmentSubmitted(
      vendorId: 'v1',
      pickupDistrictId: 'd1',
      pickupAddress: 'Village road',
      preferredPickupOn: DateTime(2026, 12, 1),
      items: const [
        {'crop_id': 'c1', 'quantity': 0, 'unit_id': 'u1'},
      ],
    );

    blocTest<RequestShipmentBloc, RequestShipmentState>(
      'loads the options when it starts',
      build: () {
        when(() => source.getShipmentOptions())
            .thenAnswer((_) async => ShipmentOptionsModel());
        return RequestShipmentBloc(source);
      },
      act: (bloc) => bloc.add(const RequestShipmentStarted()),
      expect: () => [
        const RequestShipmentState(status: RequestShipmentStatus.loading),
        isA<RequestShipmentState>()
            .having((s) => s.status, 'status', RequestShipmentStatus.ready)
            .having((s) => s.options, 'options', isNotNull),
      ],
    );

    blocTest<RequestShipmentBloc, RequestShipmentState>(
      'puts the server\'s item errors on the item field, and clears one on edit',
      build: () {
        when(
          () => source.requestShipment(
            vendorId: any(named: 'vendorId'),
            pickupDistrictId: any(named: 'pickupDistrictId'),
            pickupAddress: any(named: 'pickupAddress'),
            preferredPickupOn: any(named: 'preferredPickupOn'),
            items: any(named: 'items'),
            notes: any(named: 'notes'),
          ),
        ).thenThrow(
          const ValidationException(
            'The quantity must be greater than 0.',
            fieldErrors: {
              'items.0.quantity': 'The quantity must be greater than 0.',
            },
          ),
        );
        return RequestShipmentBloc(source);
      },
      act: (bloc) async {
        bloc.add(submitted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RequestShipmentFieldErrorCleared('items.0.quantity'));
      },
      expect: () => [
        const RequestShipmentState(status: RequestShipmentStatus.submitting),
        const RequestShipmentState(
          status: RequestShipmentStatus.failure,
          errorMessage: 'The quantity must be greater than 0.',
          fieldErrors: {
            'items.0.quantity': 'The quantity must be greater than 0.',
          },
        ),
        const RequestShipmentState(status: RequestShipmentStatus.failure),
      ],
    );

    blocTest<RequestShipmentBloc, RequestShipmentState>(
      'sends the items and succeeds',
      build: () {
        when(
          () => source.requestShipment(
            vendorId: 'v1',
            pickupDistrictId: 'd1',
            pickupAddress: 'Village road',
            preferredPickupOn: DateTime(2026, 12, 1),
            items: any(named: 'items'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer((_) async => true);
        return RequestShipmentBloc(source);
      },
      act: (bloc) => bloc.add(submitted()),
      expect: () => [
        const RequestShipmentState(status: RequestShipmentStatus.submitting),
        const RequestShipmentState(status: RequestShipmentStatus.success),
      ],
      verify: (_) => verify(
        () => source.requestShipment(
          vendorId: 'v1',
          pickupDistrictId: 'd1',
          pickupAddress: 'Village road',
          preferredPickupOn: DateTime(2026, 12, 1),
          items: const [
            {'crop_id': 'c1', 'quantity': 0, 'unit_id': 'u1'},
          ],
          notes: null,
        ),
      ).called(1),
    );
  });

  group('ShipmentDetailBloc cancel', () {
    test('cancels with the reason, reloads, and completes', () async {
      final cancelled = ShipmentModel(id: 's1', actions: const []);
      when(() => source.cancelShipment('s1', reason: 'Not ready'))
          .thenAnswer((_) async => true);
      when(() => source.getShipment('s1')).thenAnswer((_) async => cancelled);
      final bloc = ShipmentDetailBloc(source);
      final completer = Completer<void>();

      bloc.add(
        ShipmentActionSubmitted(
          shipment: 's1',
          action: ShipmentAction.cancel,
          reason: 'Not ready',
          completer: completer,
        ),
      );
      await completer.future;

      expect(bloc.state.shipmentDetails, cancelled);
      verify(() => source.cancelShipment('s1', reason: 'Not ready')).called(1);
      await bloc.close();
    });

    test('hands the server error to the sheet', () async {
      when(() => source.cancelShipment('s1', reason: 'x'))
          .thenThrow(const ValidationException('Too late to cancel.'));
      final bloc = ShipmentDetailBloc(source);
      final completer = Completer<void>();

      bloc.add(
        ShipmentActionSubmitted(
          shipment: 's1',
          action: ShipmentAction.cancel,
          reason: 'x',
          completer: completer,
        ),
      );

      await expectLater(completer.future, throwsA(isA<ValidationException>()));
      await bloc.close();
    });
  });

  group('vendor', () {
    blocTest<ShipmentsBloc, ShipmentsState>(
      'a vendor\'s list comes from the vendor endpoint',
      build: () {
        when(
          () => source.getVendorShipments(
            open: 1,
            page: 1,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => Paged(items: [active]));
        return ShipmentsBloc(source);
      },
      act: (bloc) =>
          bloc.add(const ShipmentsStarted(party: ShipmentParty.vendor)),
      verify: (bloc) {
        expect(bloc.state.party, ShipmentParty.vendor);
        expect(bloc.state.shipments?.items, [active]);
        verifyNever(
          () => source.getShipments(
            open: any(named: 'open'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );

    Future<ShipmentDetailBloc> vendorDetail() async {
      when(() => source.getVendorShipment('s1'))
          .thenAnswer((_) async => active);
      final bloc = ShipmentDetailBloc(source)
        ..add(
          const ShipmentDetailStarted(
            shipment: 's1',
            party: ShipmentParty.vendor,
          ),
        );
      await bloc.stream.firstWhere((s) => s.shipmentDetails != null);
      return bloc;
    }

    test(
      'accepting sends the vehicle and driver, then reloads as vendor',
      () async {
        when(() => source.acceptShipment('s1', vehicleId: 'v1', driverId: 'd1'))
            .thenAnswer((_) async => true);
        final bloc = await vendorDetail();
        final completer = Completer<void>();

        bloc.add(
          ShipmentActionSubmitted(
            shipment: 's1',
            action: ShipmentAction.accept,
            vehicleId: 'v1',
            driverId: 'd1',
            completer: completer,
          ),
        );
        await completer.future;

        verify(
          () => source.acceptShipment('s1', vehicleId: 'v1', driverId: 'd1'),
        ).called(1);
        verify(() => source.getVendorShipment('s1')).called(2);
        verifyNever(() => source.getShipment(any()));
        await bloc.close();
      },
    );

    test('receiving sends a quantity per item', () async {
      when(() => source.receiveShipment('s1', quantities: {'i1': 12.5}))
          .thenAnswer((_) async => true);
      final bloc = await vendorDetail();
      final completer = Completer<void>();

      bloc.add(
        ShipmentActionSubmitted(
          shipment: 's1',
          action: ShipmentAction.receive,
          quantities: const {'i1': 12.5},
          completer: completer,
        ),
      );
      await completer.future;

      verify(() => source.receiveShipment('s1', quantities: {'i1': 12.5}))
          .called(1);
      await bloc.close();
    });

    test('assignment options are handed to the sheet', () async {
      final options = AssignmentOptionsModel();
      when(() => source.getAssignmentOptions('s1'))
          .thenAnswer((_) async => options);
      final bloc = ShipmentDetailBloc(source);
      final completer = Completer<AssignmentOptionsModel?>();

      bloc.add(
        ShipmentAssignmentOptionsRequested(
          shipment: 's1',
          completer: completer,
        ),
      );

      expect(await completer.future, same(options));
      await bloc.close();
    });
  });

  group('driver', () {
    blocTest<ShipmentsBloc, ShipmentsState>(
      'a driver\'s list comes from the driver endpoint',
      build: () {
        when(
          () => source.getDriverShipments(
            open: 1,
            page: 1,
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => Paged(items: [active]));
        return ShipmentsBloc(source);
      },
      act: (bloc) =>
          bloc.add(const ShipmentsStarted(party: ShipmentParty.driver)),
      verify: (bloc) => expect(bloc.state.shipments?.items, [active]),
    );

    Future<ShipmentDetailBloc> driverDetail() async {
      when(() => source.getDriverShipment('s1'))
          .thenAnswer((_) async => active);
      final bloc = ShipmentDetailBloc(source)
        ..add(
          const ShipmentDetailStarted(
            shipment: 's1',
            party: ShipmentParty.driver,
          ),
        );
      await bloc.stream.firstWhere((s) => s.shipmentDetails != null);
      return bloc;
    }

    test('confirming the pickup sends the picked quantities', () async {
      when(() => source.createConfirmPickup('s1', quantities: {'i1': 10.0}))
          .thenAnswer((_) async => true);
      final bloc = await driverDetail();
      final completer = Completer<void>();

      bloc.add(
        ShipmentActionSubmitted(
          shipment: 's1',
          action: ShipmentAction.pickup,
          quantities: const {'i1': 10.0},
          completer: completer,
        ),
      );
      await completer.future;

      verify(() => source.createConfirmPickup('s1', quantities: {'i1': 10.0}))
          .called(1);
      verify(() => source.getDriverShipment('s1')).called(2);
      await bloc.close();
    });

    test(
      'recording picked quantities and reaching call their endpoints',
      () async {
        when(() => source.updateRecordPicked('s1', quantities: {'i1': 9.5}))
            .thenAnswer((_) async => true);
        when(() => source.markReached('s1')).thenAnswer((_) async => true);
        final bloc = await driverDetail();

        for (final event in [
          (ShipmentAction.recordPicked, const {'i1': 9.5}),
          (ShipmentAction.reach, null),
        ]) {
          final completer = Completer<void>();
          bloc.add(
            ShipmentActionSubmitted(
              shipment: 's1',
              action: event.$1,
              quantities: event.$2,
              completer: completer,
            ),
          );
          await completer.future;
        }

        verify(() => source.updateRecordPicked('s1', quantities: {'i1': 9.5}))
            .called(1);
        verify(() => source.markReached('s1')).called(1);
        await bloc.close();
      },
    );
  });
}
