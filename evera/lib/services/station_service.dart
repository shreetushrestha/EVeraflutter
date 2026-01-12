import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'session.dart';

class StationService {
  late Dio dio;

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://localhost:3000/';
  }

  StationService() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (Session.token != null && Session.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${Session.token}';
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAllStations() async {
    final response = await dio.get('api/v1/stations');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    }

    throw response.data['message'] ?? 'Failed to fetch stations';
  }

  Future<List<Map<String, dynamic>>> getMyStations() async {
    final response = await dio.get('api/v1/stations/my-stations');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }

    throw response.data['message'] ?? 'Failed to fetch my stations';
  }
}
