// To parse this JSON data, do
//
//     final evModel = evModelFromJson(jsonString);

import 'dart:convert';

List<EvModel> evModelFromJson(String str) => List<EvModel>.from(json.decode(str).map((x) => EvModel.fromJson(x)));

String evModelToJson(List<EvModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EvModel {
    String name;
    String city;
    String province;
    String address;
    String telephone;
    List<TypeElement> type;
    String latitude;
    String longitude;
    List<PlugElement>? plugs;
    List<Amenity>? amenities;
    String? time;
    

    EvModel({
        required this.name,
        required this.city,
        required this.province,
        required this.address,
        required this.telephone,
        required this.type,
        required this.latitude,
        required this.longitude,
        this.plugs,
        this.amenities,
        this.time,
    });

    EvModel copyWith({
        String? name,
        String? city,
        String? province,
        String? address,
        String? telephone,
        List<TypeElement>? type,
        String? latitude,
        String? longitude,
        List<PlugElement>? plugs,
        List<Amenity>? amenities,
        String? time,
    }) => 
        EvModel(
            name: name ?? this.name,
            city: city ?? this.city,
            province: province ?? this.province,
            address: address ?? this.address,
            telephone: telephone ?? this.telephone,
            type: type ?? this.type,
            latitude: latitude ?? this.latitude,
            longitude: longitude ?? this.longitude,
            plugs: plugs ?? this.plugs,
            amenities: amenities ?? this.amenities,
            time: time ?? this.time,
        );

    factory EvModel.fromJson(Map<String, dynamic> json) => EvModel(
        name: json["name"],
        city: json["city"],
        province: json["province"],
        address: json["address"],
        telephone: json["telephone"],
        type: List<TypeElement>.from(json["type"].map((x) => typeElementValues.map[x]!)),
        latitude: json["latitude"],
        longitude: json["longitude"],
        plugs: json["plugs"] == null ? [] : List<PlugElement>.from(json["plugs"]!.map((x) => PlugElement.fromJson(x))),
        amenities: json["amenities"] == null ? [] : List<Amenity>.from(json["amenities"]!.map((x) => amenityValues.map[x]!)),
        time: json["time"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "city": city,
        "province": province,
        "address": address,
        "telephone": telephone,
        "type": List<dynamic>.from(type.map((x) => typeElementValues.reverse[x])),
        "latitude": latitude,
        "longitude": longitude,
        "plugs": plugs == null ? [] : List<dynamic>.from(plugs!.map((x) => x.toJson())),
        "amenities": amenities == null ? [] : List<dynamic>.from(amenities!.map((x) => amenityValues.reverse[x])),
        "time": time,
    };
}

enum Amenity {
    ACCOMODATION,
    COFFEE,
    FOOD,
    PARKING,
    PETROL,
    RESTROOM,
    WIFI
}

final amenityValues = EnumValues({
    "accomodation": Amenity.ACCOMODATION,
    "coffee": Amenity.COFFEE,
    "food": Amenity.FOOD,
    "parking": Amenity.PARKING,
    "petrol": Amenity.PETROL,
    "restroom": Amenity.RESTROOM,
    "wifi": Amenity.WIFI
});

class PlugElement {
    PlugEnum plug;
    Power power;
    PlugType type;

    PlugElement({
        required this.plug,
        required this.power,
        required this.type,
    });

    PlugElement copyWith({
        PlugEnum? plug,
        Power? power,
        PlugType? type,
    }) => 
        PlugElement(
            plug: plug ?? this.plug,
            power: power ?? this.power,
            type: type ?? this.type,
        );

    factory PlugElement.fromJson(Map<String, dynamic> json) => PlugElement(
        plug: plugEnumValues.map[json["plug"]]!,
        power: powerValues.map[json["power"]]!,
        type: plugTypeValues.map[json["type"]]!,
    );

    Map<String, dynamic> toJson() => {
        "plug": plugEnumValues.reverse[plug],
        "power": powerValues.reverse[power],
        "type": plugTypeValues.reverse[type],
    };
}

enum PlugEnum {
    CCSSAE,
    TYPE2,
    WALL_BS1363
}

final plugEnumValues = EnumValues({
    "ccssae": PlugEnum.CCSSAE,
    "type2": PlugEnum.TYPE2,
    "wall-bs1363": PlugEnum.WALL_BS1363
});

enum Power {
    EMPTY,
    THE_40_KW,
    THE_72_KW,
    THE_7_KW
}

final powerValues = EnumValues({
    "": Power.EMPTY,
    "40Kw": Power.THE_40_KW,
    "7.2Kw": Power.THE_72_KW,
    "7Kw": Power.THE_7_KW
});

enum PlugType {
    AC,
    EMPTY
}

final plugTypeValues = EnumValues({
    "AC": PlugType.AC,
    "": PlugType.EMPTY
});

enum TypeElement {
    BIKE,
    CAR
}

final typeElementValues = EnumValues({
    "bike": TypeElement.BIKE,
    "car": TypeElement.CAR
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
