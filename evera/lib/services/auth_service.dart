import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

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
        lastResponse = response;

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          return response;
        }

        if (response.statusCode != null && response.statusCode! >= 500) {
          lastError = 'Server error ${response.statusCode}: ${response.data}';
          break;
        }

      } catch (e) {
        lastError = e;
        print('LOGIN ERROR on $ep: $e');
      }
    }

    if (lastResponse != null) {
      print('LOGIN FAILED - last status: ${lastResponse.statusCode} data: ${lastResponse.data}');
    } else if (lastError != null) {
      print('LOGIN FAILED - last error: $lastError');
    }

    return lastResponse;
  }

  Future<Response?> signup(
      String name, String email, String phone, String password) async {
    try {
      final response = await dio.post(
        "api/v1/auth/signup",
        data: {
          "name": name,
          "email": email,
          "phone": phone,
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
}
