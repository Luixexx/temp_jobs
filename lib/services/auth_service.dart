import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  final String token;
  final User user;
  AuthResult({required this.token, required this.user});
}

class AuthService {
  final ApiClient _api = ApiClient();

  Future<AuthResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final response = await _api.post('/auth/register', {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'referralMatricula': referralMatricula,
    });
    return _parseAuthResponse(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _parseAuthResponse(response);
  }

  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    await _api.post('/auth/forgot-password', {
      'email': email,
      'referralMatricula': referralMatricula,
    });
  }

  AuthResult _parseAuthResponse(dynamic response) {
    final data = response['data'];
    return AuthResult(token: data['token'], user: User.fromJson(data['user']));
  }

  Future<User> fetchMe() async {
    final response = await _api.get('/me', auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return User.fromJson(data);
  }

  Future<void> changePassword(String newPassword) async {
    await _api.put('/me/password', {'password': newPassword}, auth: true);
  }

  Future<User> completeProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required String birthDate,
  }) async {
    final response = await _api.put('/me/profile', {
      'firstName': firstName,
      'lastName': lastName,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate,
    }, auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;
    return User.fromJson(data);
  }
}
