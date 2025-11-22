import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/AuthService.dart';
import 'package:flutter_application_1/DatabaseHelper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth/Database (sembast) tests', () {
    test('registers and persists a user', () async {
      // Remove existing DB to start fresh
      final dbFile = File('contacts.db');
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // initialize db
      await DatabaseHelper.instance.database;

      final email = 'auto_test@example.com';
      final password = 'password123';

      // Ensure user doesn't exist
      final preExists = await DatabaseHelper.instance.userExists(email);
      expect(preExists, false);

      // Register via AuthService
      final registered = await AuthService.instance.register(email, password);
      expect(
        registered,
        true,
        reason: 'AuthService.register should return true',
      );

      // Verify persistence
      final exists = await DatabaseHelper.instance.userExists(email);
      expect(exists, true, reason: 'User should exist in users store');

      final logged = await DatabaseHelper.instance.getLoggedInEmail();
      expect(
        logged,
        email,
        reason: 'Logged in email should be set after registration',
      );
    });
  });
}
