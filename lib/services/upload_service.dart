import 'dart:convert';
import 'dart:io';
import 'api_client.dart';

class UploadService {
  final ApiClient _api = ApiClient();

  Future<String> uploadImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Detectamos la extensión para armar el data URI correctamente
    final extension = imageFile.path.split('.').last.toLowerCase();
    final mime = extension == 'png' ? 'image/png' : 'image/jpeg';
    final dataUri = 'data:$mime;base64,$base64Image';

    final response = await _api.post('/uploads', {
      'image': dataUri,
    }, auth: true);

    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return data['url'];
  }
}
