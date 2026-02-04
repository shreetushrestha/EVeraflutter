import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'session.dart';


class AuthService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://localhost:3000/';
  }
  late Dio dio;

  AuthService() {

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) => true,
      ),
    );

    print("📡 DIO BASE URL => $baseUrl");
  }

  Future<Response?> login(String email, String password) async {
    final endpoints = [
      'api/v1/auth/log-in',
    ];

    Response? lastResponse;
    Object? lastError;

    for (final ep in endpoints) {
      try {
        print('Attempting login to: $ep');
        print('Request body: email=${email.isNotEmpty}, password=${password.isNotEmpty}');
        final response = await dio.post(
          ep,
          data: {
            'email': email,
            'password': password,
          },
          options: Options(contentType: Headers.jsonContentType),
        );

        print('LOGIN ATTEMPT ${ep} -> status: ${response.statusCode} -> url: ${response.requestOptions.uri}');
        print("LOGIN RESPONSE: ${response.statusCode} -> ${response.data}");
        
        // Save token and user data to Session if login successful
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true && data['token'] != null) {
            final userData = data['user'] as Map<String, dynamic>?;
            await Session.saveLogin(
              token: data['token'],
              role: userData?['role'] ?? 'user',
              userId: userData?['id'] ?? '',
              email: email,
            );
            print('✅ Token saved to Session');
          }
        }
        
        return response;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
    }
  }

  Future<Response?> signup(
      String name, String email, String phone, String password, String role) async {
    try {
      final response = await dio.post(
        "api/v1/auth/signup",
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "role": role,
          "password": password,
        },
      );

      print("SIGNUP RESPONSE: ${response.statusCode} -> ${response.data}");
      return response;
    } catch (e) {
      print("SIGNUP ERROR: $e");
      return null;
    }
  }

  Future<Response?> getUserById(String userId) async {
  try {
    return await dio.get(
      "/api/v1/users/$userId",
      options: Options(
        headers: {
          "Authorization": "Bearer ${Session.token}",
        },
      ),
    );
  } catch (e) {
    print("Get user error: $e");
    return null;
  }
}

}

