import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'session.dart';

class BookingService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/';
    return 'http://127.0.0.1:3000/';
  }

  late Dio dio;

  BookingService() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${Session.token}",
        },
        validateStatus: (status) => true,
      ),
    );

    print("📡 DIO BASE URL => $baseUrl");
  }

  Future<Map<String, dynamic>> createBooking({
    required String stationId,
    required String plug,
    required DateTime startDateTime,
    required double duration, // hours: 0.5, 1, 2, etc
    required int price,
  }) async {
    try {
      final response = await dio.post(
        "/api/v1/bookings",
        data: {
          "userId": Session.userId, // from session
          "stationId": stationId,
          "plug": plug,
          "startDateTime": startDateTime.toIso8601String(),
          "duration": duration,
          "price": price,
        },
      );

      if (response.statusCode == 201) {
        print("✅ Booking created successfully");
        return response.data;
      } else {
        print("❌ Booking failed: ${response.data}");
        throw Exception("Failed to create booking");
      }
    } catch (e) {
      print("BookingService error: $e");
      throw Exception("BookingService error: $e");
    }
  }

  Future<List<dynamic>> getUserBookings() async {
    try {
      final response = await dio.get("/api/v1/bookings/user/${Session.userId}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to load bookings");
      }
    } catch (e) {
      print("GetBookings error: $e");
      throw Exception("GetBookings error");
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final res = await dio.post(
        "/api/v1/bookings/update-status",
        data: {"bookingId": bookingId, "status": "cancelled"},
      );

      if (res.statusCode == 200) {
        print("✅ Booking cancelled");
        return true;
      } else {
        print("❌ Cancel failed ${res.statusCode}: ${res.data}");
        return false;
      }
    } catch (e) {
      print("❌ Cancel booking error: $e");
      return false;
    }
  }

  Future<List<dynamic>> getManagerBookings() async {
    try {
      final response = await dio.get("/api/v1/bookings/manager-bookings");

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception("Failed to fetch bookings");
      }
    } catch (e) {
      print("Manager bookings error: $e");
      throw Exception("Manager bookings error");
    }
  }
}
