import 'dart:convert';

void main() {
  final jsonStr = '''{
    "favorites": [
        {
            "isOperational": true,
            "_id": "69536b6364599d1a4ed905db",
            "name": "Hetauda Wheels Hyundai",
            "city": "Hetauda",
            "province": "",
            "address": "E - W Hwy, Hetauda 44107, Nepal",
            "telephone": "+977 57-520200",
            "type": [
                "car"
            ],
            "latitude": 27.4310334,
            "longitude": 85.0230911,
            "plugs": [
                {
                    "_id": "69a698d9d17139b1713dd96c",
                    "plug": "type2",
                    "power": "7.2Kw",
                    "type": "AC"
                }
            ],
            "amenities": [],
            "price": "Rs. 15/kWh",
            "updatedAt": "2026-02-04T03:34:23.975Z",
            "images": [
                "https://ennepalkhabar.prixacdn.net/media/gallery_folder/bharatpur_ev_charging_stations_Qy44gHryvA.jpg"
            ]
        }
    ]
}''';
  final data = json.decode(jsonStr);
  print(data.runtimeType);
  final favorites = data['favorites'];
  print(favorites.runtimeType);
  for (final fav in favorites) {
    print('element type: ${fav.runtimeType}');
    if (fav is String) {
      print('string');
    } else if (fav is Map) {
      print('map id: ${fav['_id']}');
    }
  }
}
