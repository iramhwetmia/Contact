import 'DatabaseHelper.dart';
import 'dart:developer' as developer;

class AuthService {
  AuthService._private();
  static final AuthService instance = AuthService._private();

  String? _loggedInEmail;

  Future<void> init() async {
    // Load loggedInEmail from sembast via DatabaseHelper
    _loggedInEmail = await DatabaseHelper.instance.getLoggedInEmail();
  }

  bool get isLoggedIn => _loggedInEmail != null;

  String? get currentUserEmail => _loggedInEmail;

  Future<bool> register(String email, String password) async {
    try {
      developer.log('AuthService.register: trying to register $email');
      final exists = await DatabaseHelper.instance.userExists(email);
      if (exists) {
        developer.log('AuthService.register: user exists $email');
        return false;
      }
      await DatabaseHelper.instance.saveUser(email, password);
      _loggedInEmail = email;
      await DatabaseHelper.instance.setLoggedInEmail(email);
      developer.log('AuthService.register: registration successful $email');
      return true;
    } catch (e, st) {
      developer.log('AuthService.register error: $e', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      developer.log('AuthService.login: trying to login $email');
      final ok = await DatabaseHelper.instance.checkUser(email, password);
      if (ok) {
        _loggedInEmail = email;
        await DatabaseHelper.instance.setLoggedInEmail(email);
        developer.log('AuthService.login: success $email');
        return true;
      }
      developer.log('AuthService.login: failed credentials $email');
      return false;
    } catch (e, st) {
      developer.log('AuthService.login error: $e', error: e, stackTrace: st);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      developer.log('AuthService.logout');
      _loggedInEmail = null;
      await DatabaseHelper.instance.setLoggedInEmail(null);
    } catch (e, st) {
      developer.log('AuthService.logout error: $e', error: e, stackTrace: st);
    }
  }
}
