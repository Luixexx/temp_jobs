import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true; // true mientras revisamos si hay sesión guardada

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _user != null;

  // Se llama UNA vez, al abrir la app
  Future<void> tryAutoLogin() async {
    final token = await _apiClient.getToken();
    if (token == null) {
      _isInitializing = false;
      notifyListeners();
      return;
    }

    try {
      _user = await _authService.fetchMe();
    } catch (_) {
      // El token guardado ya no sirve (expiró o es inválido) -> lo borramos
      await _apiClient.clearToken();
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      );
      await _apiClient.saveToken(result.token);
      _user = result.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(email: email, password: password);
      await _apiClient.saveToken(result.token);
      _user = result.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    _user = null;
    notifyListeners();
  }
}
