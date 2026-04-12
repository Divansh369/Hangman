import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final PocketBase pb = PocketBase('https://pocketbase.fiorejoy.com');

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('pb_auth');
    if (authData != null) {
      final decoded = jsonDecode(authData);
      pb.authStore.save(decoded['token'], decoded['model']);
    }

    pb.authStore.onChange.listen((event) {
      prefs.setString('pb_auth', jsonEncode({
        'token': event.token,
        'model': event.model,
      }));
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
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
      print('Register error: $e');
      return false;
    }
  }

  void logout() {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;
  RecordModel? get currentUser => pb.authStore.model as RecordModel?;
}
