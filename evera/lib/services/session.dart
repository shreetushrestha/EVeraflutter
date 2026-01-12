class Session {
  static String? token;
  static String? role;
  static String? userId;

  static void save({
    required String token,
    required String role,
    String? userId,
  }) {
    Session.token = token;
    Session.role = role;
    Session.userId = userId;
  }

  static void clear() {
    token = null;
    role = null;
    userId = null;
  }

  static bool get isLoggedIn => token != null;
}
