import '../models/experience.dart';
import 'api_client.dart';

class ExperienceService {
  final ApiClient _api = ApiClient();

  Future<List<Experience>> getMyExperiences() async {
    final response = await _api.get('/me/experiences', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Experience.fromJson(e)).toList();
  }

  Future<void> addExperience({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) async {
    await _api.post('/me/experiences', {
      'title': title,
      'description': description,
      if (jobTypeKey != null && jobTypeKey.isNotEmpty) 'jobTypeKey': jobTypeKey,
      'certificateImage': ?certificateImage,
    }, auth: true);
  }

  Future<void> deleteExperience(String id) async {
    await _api.delete('/me/experiences/$id', auth: true);
  }
}
