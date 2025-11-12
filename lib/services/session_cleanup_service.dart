import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SessionCleanupService {
  static const _storage = FlutterSecureStorage();

  static Future<void> cleanupExpiredSessions() async {
    try {
      final allKeys = await _storage.readAll();
      int cleaned = 0;
      int errors = 0; 

      for (final entry in allKeys.entries) {
        if (!entry.key.startsWith('session_')) continue;

        try {
          final session = json.decode(entry.value);

          
          if (session['expiresAt'] == null || session['token'] == null) {
            await _storage.delete(key: entry.key); 
            cleaned++;
            continue;
          }

          final expiresAt = DateTime.parse(session['expiresAt']);
          if (expiresAt.isBefore(DateTime.now())) {
            await _storage.delete(key: entry.key);
            cleaned++;
          }
        } catch (parseErr) {

          try {
            await _storage.delete(key: entry.key);
            cleaned++;
          } catch (delErr) {
            errors++;
          }
        }
      }

      
    } catch (e) {
    }
  }
}
