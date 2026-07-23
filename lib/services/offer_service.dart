import '../models/offer.dart';
import 'api_client.dart';

class OfferService {
  final ApiClient _api = ApiClient();

  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    final query = <String, String>{};
    if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
      query['jobTypeKey'] = jobTypeKey;
    }
    if (contractType != null && contractType.isNotEmpty) {
      query['contractType'] = contractType;
    }

    final queryString = query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    final response = await _api.get('/offers$queryString', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Offer.fromJson(e)).toList();
  }

  Future<Offer> getOfferDetail(String id) async {
    final response = await _api.get('/offers/$id', auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return Offer.fromJson(data);
  }

  Future<Offer> createOffer(Map<String, dynamic> input) async {
    final response = await _api.post('/offers', input, auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return Offer.fromJson(data);
  }

  Future<List<Offer>> getMyOffers() async {
    final response = await _api.get('/me/offers', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Offer.fromJson(e)).toList();
  }
}
