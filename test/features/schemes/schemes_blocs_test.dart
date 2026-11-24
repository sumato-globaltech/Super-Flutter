import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/paged.dart';
import 'package:super_flutter/data/schemes/model/scheme_application_model.dart';
import 'package:super_flutter/data/schemes/model/scheme_model.dart';
import 'package:super_flutter/data/schemes/sources/remote/schemes_remote_data_source.dart';
import 'package:super_flutter/data/shipments/model/shipment_party_model.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/my_applications/bloc/my_applications_event.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_event.dart';
import 'package:super_flutter/features/schemes/presentation/scheme_detail/bloc/scheme_detail_state.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_bloc.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_event.dart';
import 'package:super_flutter/features/schemes/presentation/schemes/bloc/schemes_state.dart';

class _MockSource extends Mock implements SchemesRemoteDataSource {}

void main() {
  late _MockSource source;
  final scheme = SchemeModel(id: 'sc1', name: 'Seed subsidy', isOpen: true);
  final application = SchemeApplicationModel(
    id: 'a1',
    scheme: ShipmentPartyModel(id: 'sc1', name: 'Seed subsidy'),
  );

  setUp(() => source = _MockSource());

  group('SchemesBloc', () {
    blocTest<SchemesBloc, SchemesState>(
      'everyone sees the published schemes',
      build: () {
        when(() => source.getSchemes(page: 1, perPage: any(named: 'perPage')))
            .thenAnswer((_) async => Paged(items: [scheme]));
        return SchemesBloc(source);
      },
      act: (bloc) => bloc.add(const SchemesStarted()),
      verify: (bloc) {
        expect(bloc.state.schemes?.items, [scheme]);
        expect(bloc.state.officer, isFalse);
      },
    );

    blocTest<SchemesBloc, SchemesState>(
      'officers get their own list with application counts',
      build: () {
        when(
          () =>
              source.getOfficerSchemes(page: 1, perPage: any(named: 'perPage')),
        ).thenAnswer((_) async => Paged(items: [scheme]));
        return SchemesBloc(source);
      },
      act: (bloc) => bloc.add(const SchemesStarted(officer: true)),
      verify: (bloc) {
        expect(bloc.state.officer, isTrue);
        verifyNever(
          () => source.getSchemes(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          ),
        );
      },
    );
  });

  group('SchemeDetailBloc', () {
    test('a farmer who has not applied can apply to an open scheme', () async {
      when(() => source.getScheme('sc1')).thenAnswer((_) async => scheme);
      when(() => source.getSchemeApplications(perPage: 100))
          .thenAnswer((_) async => const Paged(items: []));
      final bloc = SchemeDetailBloc(source)
        ..add(const SchemeDetailStarted(scheme: 'sc1', farmer: true));
      final loaded = await bloc.stream.firstWhere(
        (s) => s.status == SchemeDetailStatus.success,
      );
      expect(loaded.canApply, isTrue);

      when(() => source.applyScheme('sc1')).thenAnswer((_) async => true);
      when(() => source.getSchemeApplications(perPage: 100))
          .thenAnswer((_) async => Paged(items: [application]));
      final completer = Completer<void>();
      bloc.add(SchemeApplied(scheme: 'sc1', completer: completer));
      await completer.future;

      expect(bloc.state.application, application);
      expect(bloc.state.canApply, isFalse);
      await bloc.close();
    });

    test('someone who is not a farmer never gets Apply', () async {
      when(() => source.getScheme('sc1')).thenAnswer((_) async => scheme);
      final bloc = SchemeDetailBloc(source)
        ..add(const SchemeDetailStarted(scheme: 'sc1'));
      final loaded = await bloc.stream.firstWhere(
        (s) => s.status == SchemeDetailStatus.success,
      );
      expect(loaded.canApply, isFalse);
      verifyNever(() => source.getSchemeApplications(perPage: 100));
      await bloc.close();
    });

    test('the server refusing an application reaches the sheet', () async {
      when(() => source.applyScheme('sc1')).thenThrow(
        const ValidationException('You have already applied to this scheme.'),
      );
      final bloc = SchemeDetailBloc(source);
      final completer = Completer<void>();
      bloc.add(SchemeApplied(scheme: 'sc1', completer: completer));
      await expectLater(completer.future, throwsA(isA<ValidationException>()));
      await bloc.close();
    });
  });

  group('MyApplicationsBloc', () {
    setUp(() {
      when(
        () => source.getSchemeApplications(
          page: 1,
          perPage: any(named: 'perPage'),
        ),
      ).thenAnswer((_) async => Paged(items: [application]));
    });

    test('withdrawing and uploading call the API, then reload', () async {
      when(() => source.withdrawApplication('a1'))
          .thenAnswer((_) async => true);
      when(
        () => source.createApplicationDocument(
          'a1',
          name: 'Aadhaar card',
          file: '/tmp/a.pdf',
        ),
      ).thenAnswer((_) async => true);
      final bloc = MyApplicationsBloc(source);

      final upload = Completer<void>();
      bloc.add(
        ApplicationDocumentUploaded(
          application: 'a1',
          name: 'Aadhaar card',
          path: '/tmp/a.pdf',
          completer: upload,
        ),
      );
      await upload.future;
      final withdraw = Completer<void>();
      bloc.add(ApplicationWithdrawn(application: 'a1', completer: withdraw));
      await withdraw.future;

      expect(bloc.state.applications?.items, [application]);
      verify(() => source.withdrawApplication('a1')).called(1);
      verify(
        () => source.createApplicationDocument(
          'a1',
          name: 'Aadhaar card',
          file: '/tmp/a.pdf',
        ),
      ).called(1);
      await bloc.close();
    });
  });
}
