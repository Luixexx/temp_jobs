import '../models/forum.dart';
import 'api_client.dart';

class ForumService {
  final ApiClient _api = ApiClient();

  Future<List<ForumTopic>> getTopics() async {
    final response = await _api.get('/forum/topics', auth: true);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => ForumTopic.fromJson(e)).toList();
  }

  Future<ForumTopicDetail> getTopicDetail(String id) async {
    final response = await _api.get('/forum/topics/$id', auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return ForumTopicDetail.fromJson(data);
  }

  Future<void> createTopic(String title, String description) async {
    await _api.post('/forum/topics', {
      'title': title,
      'description': description,
    }, auth: true);
  }

  Future<void> addComment(String topicId, String body) async {
    await _api.post('/forum/topics/$topicId/comments', {
      'body': body,
    }, auth: true);
  }
}
