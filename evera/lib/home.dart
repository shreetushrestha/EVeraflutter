import 'package:evera/models/evmodel.dart';
import 'package:evera/services/dataservice.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
List<EvModel> items = [];
//  Dio dio = Dio();
//   String result = "";

//   // This runs once when the widget loads
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

  // Function to call your API
  // Future<void> fetchData() async {
  //   try {
  //     final response = await dio.get("http://127.0.0.1:3000/");
  //     setState(() {
  //       result = response.data.toString();
        
  //     });
  //     print(result);
  //   } catch (e) {
  //     setState(() {
  //       result = "Error: $e";
  //     });
  //   }
  // }

@override
  void initState() {
    super.initState();
    loadData();
  }
void loadData() async {
  final items = await DataService.loadItems();
setState(() {
      this.items = items;
    });

}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),
    body: content(),
    );
  }

  Widget content() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(28.20833041093028, 83.95804772177283),
        initialZoom: 11,
        interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        openStreetMapTileLayer,  
        MarkerLayer(markers: [
          if(items.isNotEmpty)
          for (var item in items)
            Marker(
            point: LatLng(double.parse(item.latitude), double.parse(item.longitude)),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                // Navigator.pushNamed(context, '/login');
              },
              child: Icon(
                Icons.location_pin,
                size: 60,
                color: Colors.red,
              )
            )
            ),
        ]
          ),
        ]);
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);

