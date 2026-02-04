import 'package:hive_flutter/hive_flutter.dart';

class Session {
  static String? token;
  static String? role;
  static String? userId;
  static String? email;

  static final _box = Hive.box('myBox');

  // SAVE (login)
  static Future<void> saveLogin({
    required String token,
    required String userId,
    required String email,
    String role = 'user',
  }) async {
    Session.token = token;
    Session.userId = userId;
    Session.email = email;
    Session.role = role;

    await _box.put('token', token);
    await _box.put('userId', userId);
    await _box.put('email', email);
    await _box.put('role', role);
  }

  // LOAD on app start
  static void loadFromHive() {
    token = _box.get('token');
    userId = _box.get('userId');
    email = _box.get('email');
    role = _box.get('role');
  }

  // LOGOUT
  static Future<void> clear() async {
    token = null;
    userId = null;
    email = null;
    role = null;

    await _box.clear();
  }

  static bool get isLoggedIn => token != null;
}
