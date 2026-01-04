import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class ApiService {
  ApiService._private();
  static final ApiService instance = ApiService._private();

  // ⚠️ IMPORTANT: Changez cette URL selon votre plateforme
  // Web/Desktop/iOS Simulator: http://localhost:8000
  // Android Emulator: http://10.0.2.2:8000
  // Appareil physique: http://[IP-DE-VOTRE-PC]:8000
  static const String baseUrl = 'http://localhost:8000';

  String? _token;

  String? get token => _token;

  void setToken(String? token) {
    _token = token;
    developer.log('ApiService: token ${token != null ? "défini" : "supprimé"}');
  }

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ==================== INSCRIPTION ====================
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      developer.log('ApiService.register: tentative pour $email');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      developer.log('ApiService.register: code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        return {'success': true, 'token': _token};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Erreur d\'inscription',
        };
      }
    } catch (e, st) {
      developer.log('ApiService.register erreur: $e', error: e, stackTrace: st);
      return {'success': false, 'error': 'Erreur de connexion au serveur'};
    }
  }

  // ==================== CONNEXION ====================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('ApiService.login: tentative pour $email');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      developer.log('ApiService.login: code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        return {'success': true, 'token': _token};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Erreur de connexion',
        };
      }
    } catch (e, st) {
      developer.log('ApiService.login erreur: $e', error: e, stackTrace: st);
      return {'success': false, 'error': 'Erreur de connexion au serveur'};
    }
  }

  // ==================== RÉCUPÉRER LES CONTACTS ====================
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      developer.log('ApiService.getContacts');
      final response = await http.get(
        Uri.parse('$baseUrl/contacts'),
        headers: _getHeaders(includeAuth: true),
      );

      developer.log('ApiService.getContacts: code ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Erreur lors de la récupération des contacts');
      }
    } catch (e, st) {
      developer.log(
        'ApiService.getContacts erreur: $e',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  // ==================== CRÉER UN CONTACT ====================
  Future<Map<String, dynamic>?> createContact(String name, String phone) async {
    try {
      developer.log('ApiService.createContact: $name');
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode({'name': name, 'phone': phone}),
      );

      developer.log('ApiService.createContact: code ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la création du contact');
      }
    } catch (e, st) {
      developer.log(
        'ApiService.createContact erreur: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ==================== METTRE À JOUR UN CONTACT ====================
  Future<Map<String, dynamic>?> updateContact(
    int id,
    String name,
    String phone,
  ) async {
    try {
      developer.log('ApiService.updateContact: $id');
      final response = await http.put(
        Uri.parse('$baseUrl/contacts/$id'),
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode({'name': name, 'phone': phone}),
      );

      developer.log('ApiService.updateContact: code ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur lors de la mise à jour du contact');
      }
    } catch (e, st) {
      developer.log(
        'ApiService.updateContact erreur: $e',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  // ==================== SUPPRIMER UN CONTACT ====================
  Future<bool> deleteContact(int id) async {
    try {
      developer.log('ApiService.deleteContact: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/contacts/$id'),
        headers: _getHeaders(includeAuth: true),
      );

      developer.log('ApiService.deleteContact: code ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e, st) {
      developer.log(
        'ApiService.deleteContact erreur: $e',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  // ==================== DÉCONNEXION ====================
  void logout() {
    _token = null;
    developer.log('ApiService: déconnecté');
  }
}
