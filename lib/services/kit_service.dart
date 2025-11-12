import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'kit_service_exception.dart';

const _storage = FlutterSecureStorage();
const SCAN_URL = 'https://scanqr-nkhk7zxbvq-uc.a.run.app';
const COMPLETE_URL = 'https://completesignup-nkhk7zxbvq-uc.a.run.app';
const LINK_KIT_URL = 'https://linkkittouser-nkhk7zxbvq-uc.a.run.app';

class KitService {
  static Future<String> getDeviceId() async {
    const key = 'tesia_device_id';
    final id = await _storage.read(key: key);
    if (id != null && id.isNotEmpty) return id;
    final newId = Uuid().v4();
    await _storage.write(key: key, value: newId);
    return newId;
  }

  static Future<Map<String, dynamic>> scanQr(String qrPayload) async {
    int retries = 2;

    while (retries > 0) {
      try {
        final deviceId = await getDeviceId();
        final kitCode = _extractKitCode(qrPayload);
        final cacheKey = 'session_$kitCode';

        final deletedKey = 'deleted_$cacheKey';
        final wasDeleted = await _storage.read(key: deletedKey);
        if (wasDeleted != null) {
          await _storage.delete(key: deletedKey);
        } else {
          final cached = await _storage.read(key: cacheKey);
          if (cached != null) {
            try {
              final m = json.decode(cached);
              if (DateTime.parse(m['expiresAt']).isAfter(DateTime.now())) {
                return {
                  'token': m['token'],
                  'expiresAt': m['expiresAt'],
                  'cached': true,
                };
              }
              await _storage.delete(key: cacheKey);
            } catch (_) {
              await _storage.delete(key: cacheKey);
            }
          }
        }

        final resp = await http
            .post(
              Uri.parse(SCAN_URL),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'code': qrPayload, 'deviceId': deviceId}),
            )
            .timeout(const Duration(seconds: 30));

        if (resp.statusCode == 200) {
          final data = json.decode(resp.body) as Map<String, dynamic>;
          final token = data['token'] as String;
          final expiresAt = data['expiresAt'] as String;

          await _storage.write(
            key: cacheKey,
            value: json.encode({
              'token': token,
              'expiresAt': expiresAt,
              'verifiedAt': DateTime.now().toIso8601String(),
            }),
          );

          return {'token': token, 'expiresAt': expiresAt};
        }

        if (resp.statusCode >= 400 && resp.statusCode < 500) {
          Map<String, dynamic> body = {};
          try {
            if (resp.body.isNotEmpty) {
              body = json.decode(resp.body);
            }
          } catch (_) {
            
          }

          final errorMsg = body['error']?.toString() ?? 'Request failed';

          String errorCode;
          switch (resp.statusCode) {
            case 404:
              errorCode = 'kit_not_found';
              break;
            case 401:
              errorCode = 'invalid_qr';
              break;
            case 409:
              errorCode = 'already_reserved';
              break;
            case 410:
              errorCode = 'already_used';
              break;
            case 400:
              errorCode = 'invalid_request';
              break;
            default:
              errorCode = 'server_error';
          }

          throw KitServiceException(errorCode, serverMessage: errorMsg);
        }

        retries--;
        if (retries == 0) {
          throw KitServiceException(
            'server_error',
            serverMessage: 'Server unavailable (${resp.statusCode})',
          );
        }

        await Future.delayed(Duration(seconds: 2));
      } on http.ClientException catch (e) {
        throw KitServiceException(
          'network_error',
          serverMessage: 'Network connection failed',
        );
      } on TimeoutException catch (e) {
        retries--;
        if (retries == 0) {
          throw KitServiceException(
            'request_timed_out',
            serverMessage: 'Request timed out',
          );
        }
        await Future.delayed(Duration(seconds: 1));
      } on KitServiceException {
        rethrow;
      } catch (e) {
        throw KitServiceException(
          'unexpected_error',
          serverMessage: e.toString(),
        );
      }
    }

    throw KitServiceException(
      'unexpected_error',
      serverMessage: 'Max retries exceeded',
    );
  }

  static Future<Map<String, dynamic>> completeSignup({
    required String sessionToken,
    required String email,
    required String password,
    required String displayName,
    String? language,
    String? theme,
  }) async {
    try {

      final resp = await http
          .post(
            Uri.parse(COMPLETE_URL),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'sessionToken': sessionToken,
              'email': email,
              'password': password,
              'displayName': displayName,
              if (language != null) 'language': language,
              if (theme != null) 'theme': theme,
            }),
          )
          .timeout(const Duration(seconds: 30));


      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return data;
      }

      Map<String, dynamic> body = {};
      try {
        if (resp.body.isNotEmpty) {
          body = json.decode(resp.body);
        }
      } catch (_) {}

      final errorMsg = body['error']?.toString() ?? 'Signup failed';

      throw KitServiceException('signup_failed', serverMessage: errorMsg);
    } on http.ClientException catch (e) {
      throw KitServiceException(
        'network_error',
        serverMessage: 'Network connection failed',
      );
    } on TimeoutException {
      throw KitServiceException(
        'request_timed_out',
        serverMessage: 'Request timed out',
      );
    } on KitServiceException {
      rethrow;
    } catch (e) {
      throw KitServiceException(
        'unexpected_error',
        serverMessage: e.toString(),
      );
    }
  }

  static Future<void> linkKitToUser({
    required String sessionToken,
    required String uid,
    String? language,
    String? theme,
  }) async {
    try {

      final resp = await http
          .post(
            Uri.parse(LINK_KIT_URL),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'sessionToken': sessionToken,
              'uid': uid,
              if (language != null) 'language': language,
              if (theme != null) 'theme': theme,
            }),
          )
          .timeout(const Duration(seconds: 30));


      if (resp.statusCode == 200) {
        return;
      }

      Map<String, dynamic> body = {};
      try {
        if (resp.body.isNotEmpty) {
          body = json.decode(resp.body);
        }
      } catch (_) {}

      final errorMsg = body['error']?.toString() ?? 'Failed to link kit';

      throw KitServiceException('link_failed', serverMessage: errorMsg);
    } on http.ClientException catch (e) {
      throw KitServiceException(
        'network_error',
        serverMessage: 'Network connection failed',
      );
    } on TimeoutException {
      throw KitServiceException(
        'request_timed_out',
        serverMessage: 'Request timed out',
      );
    } on KitServiceException {
      rethrow;
    } catch (e) {
      throw KitServiceException(
        'unexpected_error',
        serverMessage: e.toString(),
      );
    }
  }

  static String _extractKitCode(String raw) {
    try {
      final parsed = json.decode(raw);
      if (parsed is Map && parsed['code'] != null) return parsed['code'];
    } catch (_) {}
    return raw;
  }

  static Future<void> clearSession(String kitCode) async {
    final cacheKey = 'session_$kitCode';
    await _storage.delete(key: cacheKey);
    await _storage.write(key: 'deleted_$cacheKey', value: 'true');
  }
}
