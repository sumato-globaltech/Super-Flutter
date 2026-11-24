import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/crop_detector/model/crop_analysis_model.dart';

@lazySingleton
class CropDetectorRemoteDataSource {
  CropDetectorRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// POST http://dam.test/api/v1/crop-detector
  Future<CropAnalysisModel?> createCropAnalysis({
    required String image,
    bool fromGallery = false,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.cropAnalysis,
        data: FormData.fromMap(<String, dynamic>{
          'image': await MultipartFile.fromFile(image),
          'from_gallery': fromGallery ? '1' : '0',
        }),
        // The AI answers slower than the other calls.
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The crop analysis request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return CropAnalysisModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      return null;
    }
  }
}
