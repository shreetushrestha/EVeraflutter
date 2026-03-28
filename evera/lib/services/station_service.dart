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
    final headers = <String, String>{'Content-Type': 'application/json'};

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

  /// ================= GET ALL STATIONS =================
  Future<List<Map<String, dynamic>>> getAllStations() async {
    final response = await dio.get('api/v1/stations');

    if (response.statusCode == 200) {
      final data = response.data;

      // Backend might return list directly OR wrapped
      final List stations = data is List
          ? data
          : (data['data'] ?? data['stations']);

      return List<Map<String, dynamic>>.from(stations);
    }

    throw Exception(response.data?['message'] ?? 'Failed to fetch stations');
  }

  /// ================= GET MY STATIONS =================
  Future<List<Map<String, dynamic>>> getMyStations() async {
    final response = await dio.get('api/v1/stations/my-stations');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }

    throw Exception(response.data?['message'] ?? 'Failed to fetch my stations');
  }

  Future toggleOperational(String stationId, bool isOperational) async {
    await dio.patch(
      "/stations/toggle-operational",
      data: {"stationId": stationId, "isOperational": isOperational},
    );
  }

  /// ================= GET STATION BY ID =================
  Future<Map<String, dynamic>> getStationById(String id) async {
    final response = await dio.get('api/v1/stations/$id');

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    }

    throw Exception(
      response.data?['message'] ?? 'Failed to fetch station by id',
    );
  }

  /// ================= FAVORITES =================
  Future<void> addFavorite(String stationId) async {
    final response = await dio.post('api/v1/favorites/$stationId');
    debugPrint(
      'addFavorite status: ${response.statusCode}, body: ${response.data}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      // avoid indexing into a non-map body
      String msg = 'Failed to add favorite';
      if (response.data is Map && response.data['message'] != null) {
        msg = response.data['message'].toString();
      }
      throw Exception(msg);
    }
  }

  Future<void> removeFavorite(String stationId) async {
    final response = await dio.post(
      'api/v1/favorites/removeFavorite/$stationId',
    );
    debugPrint(
      'removeFavorite status: ${response.statusCode}, body: ${response.data}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      String msg = 'Failed to remove favorite';
      if (response.data is Map && response.data['message'] != null) {
        msg = response.data['message'].toString();
      }
      throw Exception(msg);
    }
  }

  Future<List<String>> getFavorites() async {
    try {
      final response = await dio.get('api/v1/favorites');
      debugPrint('Favorites status: ${response.statusCode}');
      debugPrint('Favorites Response (raw): ${response.data}');
      final data = response.data;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (data == null) {
          return [];
        }

        // Handle different response formats
        List? favorites;
        if (data is List) {
          favorites = data;
          debugPrint('Favorites is a List');
        } else if (data is Map) {
          favorites = data['favorites'];
          debugPrint('Favorites extracted from Map: $favorites');
        }

        if (favorites == null) {
          debugPrint('Favorites is null, returning empty list');
          return [];
        }

        // Extract IDs from the list safely
        final result = <String>[];
        for (final fav in favorites) {
          if (fav is String) {
            result.add(fav);
          } else if (fav is Map) {
            final id = (fav['_id'] ?? fav['id'] ?? '').toString();
            if (id.isNotEmpty) result.add(id);
          }
        }
        debugPrint('Parsed favorite IDs: $result');
        return result;
      }

      throw Exception(
        'Failed to fetch favorites (${response.statusCode}): ${response.data}',
      );
    } catch (e) {
      debugPrint('getFavorites error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchStations(String keyword) async {
    final response = await dio.get(
      'api/v1/stations/search',
      queryParameters: {'keyword': keyword},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }

    throw Exception('Failed to search stations');
  }
}
