import '../models/video_item.dart';
import 'api_client.dart';

class VideoService {
  final ApiClient _api = ApiClient();

  Future<List<VideoItem>> getVideos() async {
    final response = await _api.get('/videos', auth: false);
    final list = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return (list as List).map((e) => VideoItem.fromJson(e)).toList();
  }
}
