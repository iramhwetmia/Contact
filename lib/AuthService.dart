import 'ApiService.dart';
import 'DatabaseHelper.dart';
import 'dart:developer' as developer;

class AuthService {
  AuthService._private();
  static final AuthService instance = AuthService._private();

  String? _loggedInEmail;
  String? _token;

  Future<void> init() async {
    // Charger l'email et le token depuis le stockage local
    _loggedInEmail = await DatabaseHelper.instance.getLoggedInEmail();
    _token = await DatabaseHelper.instance.getToken();

    if (_token != null) {
      ApiService.instance.setToken(_token);
    }

    developer.log(
      'AuthService.init: email=$_loggedInEmail, hasToken=${_token != null}',
    );
  }

  bool get isLoggedIn => _loggedInEmail != null && _token != null;

  String? get currentUserEmail => _loggedInEmail;
  String? get token => _token;

  // ==================== INSCRIPTION ====================
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      developer.log('AuthService.register: $email');

      final result = await ApiService.instance.register(email, password);

      if (result['success'] == true) {
        _loggedInEmail = email;
        _token = result['token'];

        // Sauvegarder localement
        await DatabaseHelper.instance.setLoggedInEmail(email);
        await DatabaseHelper.instance.setToken(_token);

        ApiService.instance.setToken(_token);

        developer.log('AuthService.register: succès $email');
        return {'success': true};
      } else {
        developer.log('AuthService.register: échec - ${result['error']}');
        return {'success': false, 'error': result['error']};
      }
    } catch (e, st) {
      developer.log(
        'AuthService.register erreur: $e',
        error: e,
        stackTrace: st,
      );
      return {'success': false, 'error': 'Erreur lors de l\'inscription'};
    }
  }

  // ==================== CONNEXION ====================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('AuthService.login: $email');

      final result = await ApiService.instance.login(email, password);

      if (result['success'] == true) {
        _loggedInEmail = email;
        _token = result['token'];

        // Sauvegarder localement
        await DatabaseHelper.instance.setLoggedInEmail(email);
        await DatabaseHelper.instance.setToken(_token);

        ApiService.instance.setToken(_token);

        developer.log('AuthService.login: succès $email');
        return {'success': true};
      } else {
        developer.log('AuthService.login: échec - ${result['error']}');
        return {'success': false, 'error': result['error']};
      }
    } catch (e, st) {
      developer.log('AuthService.login erreur: $e', error: e, stackTrace: st);
      return {'success': false, 'error': 'Erreur lors de la connexion'};
    }
  }

  // ==================== DÉCONNEXION ====================
  Future<void> logout() async {
    try {
      developer.log('AuthService.logout');
      _loggedInEmail = null;
      _token = null;

      await DatabaseHelper.instance.setLoggedInEmail(null);
      await DatabaseHelper.instance.setToken(null);

      ApiService.instance.logout();
    } catch (e, st) {
      developer.log('AuthService.logout erreur: $e', error: e, stackTrace: st);
    }
  }
}
