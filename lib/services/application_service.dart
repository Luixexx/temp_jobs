import '../models/application.dart';
import 'api_client.dart';

class ApplicationService {
  final ApiClient _api = ApiClient();

  Future<void> apply(String offerId, String comment) async {
    await _api.post('/offers/$offerId/apply', {'comment': comment}, auth: true);
  }

  Future<List<Application>> getMyApplications() async {
    final response = await _api.get('/me/applications', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Application.fromJson(e)).toList();
  }

  Future<List<Application>> getOfferApplications(String offerId) async {
    final response = await _api.get(
      '/offers/$offerId/applications',
      auth: true,
    );
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Application.fromJson(e)).toList();
  }

  Future<void> updateApplication(
    String applicationId, {
    int? rating,
    String? status,
    num? salary,
    String? currency,
    String? startDate,
    String? duration,
  }) async {
    final body = <String, dynamic>{
      'rating': ?rating,
      'status': ?status,
      'salary': ?salary,
      'currency': ?currency,
      'startDate': ?startDate,
      'duration': ?duration,
    };
    await _api.patch('/applications/$applicationId', body, auth: true);
  }
}
