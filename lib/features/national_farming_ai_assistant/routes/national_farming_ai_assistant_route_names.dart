/// Route paths owned by the National Farming AI Assistant feature.
abstract final class NationalFarmingAiAssistantRouteNames {
  static const root = '/national_farming_ai_assistant';

  static String forCrop(String slug) =>
      Uri(path: root, queryParameters: {'crop': slug}).toString();
}
