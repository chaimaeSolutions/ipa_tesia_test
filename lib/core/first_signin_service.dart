import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirstSignInService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'has_signed_in_before';

  static Future<bool> isFirstSignIn() async {
    final value = await _storage.read(key: _key);
    return value == null || value != 'true';
  }

  static Future<void> markFirstSignInComplete() async {
    await _storage.write(key: _key, value: 'true');
  }

  static Future<void> markSignInComplete() async {
    await markFirstSignInComplete();
  }

  static Future<void> resetFirstSignIn() async {
    await _storage.delete(key: _key);
  }
}
