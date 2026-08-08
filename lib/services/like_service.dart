import '../models/offer.dart';
import 'api_client.dart';

class LikeService {
  final ApiClient _api = ApiClient();

  Future<void> like(String offerId) async {
    await _api.post('/offers/$offerId/like', {}, auth: true);
  }

  Future<void> unlike(String offerId) async {
    await _api.delete('/offers/$offerId/like', auth: true);
  }

  Future<List<Offer>> getMyLikes() async {
    final response = await _api.get('/me/likes', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => Offer.fromJson(e)).toList();
  }
}
