import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final PocketBase pb = PocketBase('https://pocketbase.fiorejoy.com');
  String? lastError;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('pb_auth');
    if (authData != null) {
      try {
        final decoded = jsonDecode(authData) as Map<String, dynamic>;
        final token = decoded['token'] as String?;
        String? userId;
        if (decoded.containsKey('userId')) {
          userId = decoded['userId'] as String?;
        } else if (decoded['model'] is Map) {
          userId = (decoded['model'] as Map)['id'] as String?;
        }

        if (token != null) {
          // Save a minimal auth state first so other calls can inspect the token.
          if (userId != null) {
            try {
              pb.authStore.save(token, RecordModel({'id': userId}));
              // Try refreshing auth token and user record from server.
              try {
                await pb.collection('users').authRefresh();
              } catch (_) {
                // Token may have expired; try fetching the record directly.
                try {
                  final full = await pb.collection('users').getOne(userId);
                  pb.authStore.save(token, full);
                } catch (e) {
                  debugPrint('AuthService: failed to refresh user record: $e');
                }
              }
              } catch (e) {
              debugPrint('AuthService: failed to refresh user record: $e');
            }
          } else {
            try {
              pb.authStore.save(token, RecordModel({}));
            } catch (e) {
              debugPrint('AuthService: failed to set minimal auth store: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('AuthService.init: failed to parse stored auth: $e');
        await prefs.remove('pb_auth');
      }
    }

    pb.authStore.onChange.listen((event) {
      try {
        final record = event.record;
        final map = <String, dynamic>{'token': event.token};
        if (record != null) map['userId'] = record.id;
        prefs.setString('pb_auth', jsonEncode(map));
      } catch (e) {
        debugPrint('AuthService: failed to persist auth: $e');
      }
    });
  }

  Future<bool> login(String email, String password) async {
    lastError = null;
    try {
      await pb.collection('users').authWithPassword(email, password);
      lastError = null;
      return true;
    } catch (e) {
      lastError = e.toString();
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    lastError = null;
    try {
      await pb.collection('users').create(body: {
        'username': username,
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'score': 0,
      });
      return await login(email, password);
    } catch (e) {
      lastError = e.toString();
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pb_auth');
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;
  RecordModel? get currentUser => pb.authStore.record;
}
