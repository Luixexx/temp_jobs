import '../models/job_type.dart';
import 'api_client.dart';

class CatalogService {
  final ApiClient _api = ApiClient();

  Future<List<JobType>> getJobTypes() async {
    final response = await _api.get('/job-types', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => JobType.fromJson(e)).toList();
  }
}
