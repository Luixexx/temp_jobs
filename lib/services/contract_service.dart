import '../models/contract.dart';
import 'api_client.dart';

class ContractService {
  final ApiClient _api = ApiClient();

  Future<List<Contract>> getMyContracts({String? status}) async {
    final query = (status != null && status.isNotEmpty)
        ? '?status=$status'
        : '';
    final response = await _api.get('/me/contracts$query', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Contract.fromJson(e)).toList();
  }

  Future<Contract> getContractDetail(String id) async {
    final response = await _api.get('/contracts/$id', auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return Contract.fromJson(data);
  }

  Future<void> setTerms(
    String id, {
    required num salary,
    String currency = 'DOP',
    required String startDate,
    required String duration,
  }) async {
    await _api.put('/contracts/$id/terms', {
      'salary': salary,
      'currency': currency,
      'startDate': startDate,
      'duration': duration,
    }, auth: true);
  }

  Future<void> accept(String id) async {
    await _api.post('/contracts/$id/accept', {}, auth: true);
  }

  Future<void> reject(String id) async {
    await _api.post('/contracts/$id/reject', {}, auth: true);
  }

  Future<void> addComment(String id, String body) async {
    await _api.post('/contracts/$id/comments', {'body': body}, auth: true);
  }

  Future<void> addPhoto(
    String id,
    String photoUrlOrBase64,
    String description,
  ) async {
    await _api.post('/contracts/$id/photos', {
      'photo': photoUrlOrBase64,
      'description': description,
    }, auth: true);
  }

  Future<void> cancel(String id, String justification) async {
    await _api.post('/contracts/$id/cancel', {
      'justification': justification,
    }, auth: true);
  }
}
