import 'dart:convert';

List<EvModel> evModelFromJson(String str) =>
    List<EvModel>.from(json.decode(str).map((x) => EvModel.fromJson(x)));

class EvModel {
  final String id;
  final String name;
  final String city;
  final String province;
  final String address;
  final String telephone;
  final double latitude;
  final double longitude;
  final List<String> type;
  final List<String> images;
  final String price;
  final List<Plug> plugs;
  final List<String> amenities;
  final bool isOperational;

  EvModel({
    required this.id,
    required this.name,
    required this.city,
    required this.province,
    required this.address,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.images,
    required this.price,
    required this.plugs,
    required this.amenities,
    required this.isOperational,
  });

  factory EvModel.fromJson(Map<String, dynamic> json) {
    return EvModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      address: json['address'] ?? '',
      telephone: json['telephone'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      type: List<String>.from(json['type'] ?? []),

      /// 🔥 FIXED PLUG PARSING
      plugs: (json['plugs'] as List? ?? [])
          .map((p) => Plug.fromJson(p))
          .toList(),

      amenities: List<String>.from(json['amenities'] ?? []),
      price: json['price'] ?? "",
      isOperational: json['isOperational'] is bool
          ? json['isOperational']
          : true,
    );
  }
}

class Plug {
  final String plug;
  final String power;
  final String type;

  Plug({required this.plug, required this.power, required this.type});

  factory Plug.fromJson(Map<String, dynamic> json) {
    return Plug(
      plug: json["plug"] ?? "",
      power: json["power"] ?? "",
      type: json["type"] ?? "",
    );
  }
}
