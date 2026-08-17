import '../models/news_item.dart';
import 'api_client.dart';

class NewsService {
  final ApiClient _api = ApiClient();

  Future<List<NewsItem>> getNews() async {
    final response = await _api.get('/news', auth: false);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => NewsItem.fromJson(e)).toList();
  }
}
