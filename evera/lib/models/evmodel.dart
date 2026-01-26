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
  final List<String> amenities;
  final List<Plug> plugs;

  final String? time;

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
    required this.amenities,
    required this.plugs,
    this.time,
  });

  factory EvModel.fromJson(Map<String, dynamic> json) {
    return EvModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "Unknown Station",
      city: json["city"] ?? "",
      province: json["province"] ?? "",
      address: json["address"] ?? "",
      telephone: json["telephone"] ?? "",

      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),

      type: json["type"] != null
          ? List<String>.from(json["type"])
          : [],

      amenities: json["amenities"] != null
          ? List<String>.from(json["amenities"])
          : [],

      plugs: json["plugs"] != null
    ? List<Plug>.from(
        (json["plugs"] as List).map((x) {
          if (x is Map<String, dynamic>) {
            return Plug.fromJson(x);
          } else if (x is String) {
            return Plug(plug: x, power: "", type: x);
          }
          return Plug(plug: "", power: "", type: "");
        }),
      )
    : [],

      time: json["time"],
    );
  }
}

class Plug {
  final String plug;
  final String power;
  final String type;

  Plug({
    required this.plug,
    required this.power,
    required this.type,
  });

  factory Plug.fromJson(Map<String, dynamic> json) {
    return Plug(
      plug: json["plug"] ?? "",
      power: json["power"] ?? "",
      type: json["type"] ?? "",
    );
  }

}
