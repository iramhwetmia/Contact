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

  final _store = intMapStoreFactory.store('contacts');
  final _usersStore = stringMapStoreFactory.store('users');
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

    // Use current directory for desktop to avoid path_provider (plugin)
    final dir = Directory.current;
    final dbPath = join(dir.path, 'contacts.db');
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    final records = await _store.find(db);
    // return newest first
    final list = records.reversed.map((snap) {
      final data = Map<String, dynamic>.from(snap.value);
      data['id'] = snap.key;
      return data;
    }).toList();
    return list;
  }

  Future<int> insertContact(Map<String, dynamic> contact) async {
    final db = await database;
    final data = Map<String, dynamic>.from(contact);
    data.remove('id');
    final key = await _store.add(db, data);
    return key;
  }

  Future<int> updateContact(int id, Map<String, dynamic> contact) async {
    final db = await database;
    final data = Map<String, dynamic>.from(contact);
    data.remove('id');
    await _store.record(id).update(db, data);
    return id;
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    await _store.record(id).delete(db);
    return id;
  }

  // --- User management using sembast stores ---
  Future<bool> userExists(String email) async {
    final db = await database;
    final rec = await _usersStore.record(email).get(db);
    return rec != null;
  }

  Future<void> saveUser(String email, String password) async {
    final db = await database;
    await _usersStore.record(email).put(db, {'password': password});
  }

  Future<bool> checkUser(String email, String password) async {
    final db = await database;
    final rec =
        await _usersStore.record(email).get(db) as Map<String, dynamic>?;
    if (rec == null) return false;
    return rec['password'] == password;
  }

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
}
