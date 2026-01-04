import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sembast_web/sembast_web.dart' show databaseFactoryWeb;
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // On garde seulement le store 'meta' pour stocker l'email et le token
  final _metaStore = stringMapStoreFactory.store('meta');
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      return await databaseFactoryWeb.openDatabase('contacts.db');
    }

    final dir = Directory.current;
    final dbPath = join(dir.path, 'contacts.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  // ==================== STOCKAGE DE L'EMAIL ====================
  Future<void> setLoggedInEmail(String? email) async {
    final db = await database;
    if (email == null) {
      await _metaStore.record('loggedInEmail').delete(db);
    } else {
      await _metaStore.record('loggedInEmail').put(db, {'value': email});
    }
  }

  Future<String?> getLoggedInEmail() async {
    final db = await database;
    final rec =
        await _metaStore.record('loggedInEmail').get(db)
            as Map<String, dynamic>?;
    return rec == null ? null : rec['value'] as String?;
  }

  // ==================== STOCKAGE DU TOKEN JWT ====================
  Future<void> setToken(String? token) async {
    final db = await database;
    if (token == null) {
      await _metaStore.record('authToken').delete(db);
    } else {
      await _metaStore.record('authToken').put(db, {'value': token});
    }
  }

  Future<String?> getToken() async {
    final db = await database;
    final rec =
        await _metaStore.record('authToken').get(db) as Map<String, dynamic>?;
    return rec == null ? null : rec['value'] as String?;
  }
}
