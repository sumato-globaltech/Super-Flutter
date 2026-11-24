import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:super_flutter/core/error/app_exception.dart';
import 'package:super_flutter/core/error/exceptions/validation_exception.dart';
import 'package:super_flutter/core/network/api_endpoints.dart';
import 'package:super_flutter/core/network/dio_client.dart';
import 'package:super_flutter/core/network/network_exception_mapper.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_answer_model.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_language_model.dart';
import 'package:super_flutter/data/national_farming_ai_assistant/model/national_farming_ai_assistant_question_model.dart';

@lazySingleton
class NationalFarmingAiAssistantRemoteDataSource {
  NationalFarmingAiAssistantRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// GET http://dam.test/api/v1/national-farming-ai-assistant/languages
  Future<List<NationalFarmingAiAssistantLanguageModel>>
  getNationalFarmingAiAssistantLanguages() async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.nationalFarmingAiAssistantLanguages,
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'];
        final items = data is List
            ? data
            : (data is Map && data['data'] is List
                  ? data['data'] as List
                  : null);
        if (items != null) {
          return items
              .whereType<Map>()
              .map(
                (item) => NationalFarmingAiAssistantLanguageModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      return const [];
    }
  }

  /// POST http://dam.test/api/v1/national-farming-ai-assistant/chat
  Future<NationalFarmingAiAssistantAnswerModel?>
  createNationalFarmingAiAssistantAnswer({
    required String question,
    required String sessionId,
    required String language,
    bool useLocation = false,
    String? image,
  }) async {
    try {
      final response = await _dioClient.dio.post<dynamic>(
        ApiEndpoints.nationalFarmingAiAssistantAnswer,
        data: FormData.fromMap(<String, dynamic>{
          'question': question,
          'session_id': sessionId,
          'language': language,
          'use_location': useLocation ? '1' : '0',
          if (image != null) 'image': await MultipartFile.fromFile(image),
        }),
        // The AI answers slower than the other calls.
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 100),
        ),
      );
      final body = response.data;
      if (body is Map && body['success'] == false) {
        final message =
            (body['message'] as String?) ?? 'The answer request failed.';
        final fieldErrors = NetworkException.fieldErrorsFrom(body);
        if (fieldErrors.isNotEmpty) {
          throw ValidationException(message, fieldErrors: fieldErrors);
        }
        throw BadRequestException(message, statusCode: response.statusCode);
      }
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map) {
        final data = body['data'] is Map ? body['data'] as Map : body;
        return NationalFarmingAiAssistantAnswerModel.fromJson(
          Map<String, dynamic>.from(data),
        );
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

  /// GET http://dam.test/api/v1/national-farming-ai-assistant/crops/{crop}/questions
  Future<List<NationalFarmingAiAssistantQuestionModel>>
  getNationalFarmingAiAssistantQuestions({
    required String crop,
    required String language,
  }) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        ApiEndpoints.nationalFarmingAiAssistantQuestions(crop),
        queryParameters: <String, dynamic>{'language': language},
      );
      final body = response.data;
      if (response.statusCode == 200 && body is Map) {
        final data = body['data'];
        final items = data is List
            ? data
            : (data is Map && data['data'] is List
                  ? data['data'] as List
                  : null);
        if (items != null) {
          return items
              .whereType<Map>()
              .map(
                (item) => NationalFarmingAiAssistantQuestionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on NetworkException {
      rethrow;
    } catch (e) {
      return const [];
    }
  }
}
