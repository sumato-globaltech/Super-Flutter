import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/data/crop_detector/sources/remote/crop_detector_remote_data_source.dart';

import 'crop_detector_event.dart';
import 'crop_detector_state.dart';

@injectable
class CropDetectorBloc extends Bloc<CropDetectorEvent, CropDetectorState> {
  CropDetectorBloc(this._cropDetectorRemoteDataSource)
    : super(const CropDetectorState()) {
    on<CropPhotoChosen>(_onPhotoChosen, transformer: droppable());
  }

  final CropDetectorRemoteDataSource _cropDetectorRemoteDataSource;

  Future<void> _onPhotoChosen(
    CropPhotoChosen event,
    Emitter<CropDetectorState> emit,
  ) async {
    emit(
      CropDetectorState(
        status: CropDetectorStatus.analysing,
        photo: event.path,
        fromGallery: event.fromGallery,
      ),
    );
    String? message;
    try {
      final analysis = await _cropDetectorRemoteDataSource.createCropAnalysis(
        image: event.path,
        fromGallery: event.fromGallery,
      );
      if (analysis != null) {
        emit(
          CropDetectorState(
            status: CropDetectorStatus.success,
            photo: event.path,
            fromGallery: event.fromGallery,
            analysis: analysis,
          ),
        );
        return;
      }
    } on AppException catch (e) {
      message = e.message;
    } catch (_) {}
    emit(
      CropDetectorState(
        status: CropDetectorStatus.failure,
        photo: event.path,
        fromGallery: event.fromGallery,
        errorMessage: message,
      ),
    );
  }
}
