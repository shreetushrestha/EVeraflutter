import 'package:evera/models/evmodel.dart';
import 'package:evera/services/dataservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'pages/search.dart';
import 'pages/bookings.dart';
import 'pages/settings.dart';
import 'pages/profile.dart';
import 'services/station_service.dart';
import 'services/session.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapController _mapController = MapController();
  List<EvModel> items = [];
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    loadData();
    getUserLocation();
  }

  /// LOAD STATIONS
  void loadData() async {
    final items = await DataService.loadItems();
    setState(() {
      this.items = items;
    });
  }

  /// USER LOCATION
  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    userLocation = LatLng(position.latitude, position.longitude);
    setState(() {});

    _mapController.move(userLocation!, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ================= MAP (UNCHANGED) =================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(28.20833, 83.95804),
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom |
                    InteractiveFlag.flingAnimation,
              ),
            ),
            children: [
              
              openStreetMapTileLayer,

              /// USER LOCATION
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),

              /// STATIONS
              MarkerLayer(
                markers: items.map((item) {
                  return Marker(
                    width: 46,
                    height: 46,
                    point: LatLng(
                      double.parse(item.latitude),
                      double.parse(item.longitude),
                    ),
                    child: chargerMarker(),
                  );
                }).toList(),
              ),
            ],
          ),

          /// ================= STATIONS CONTAINER =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: stationsContainer(),
          ),
        ],
      ),

      /// ================= STATIC NAV BAR =================
      bottomNavigationBar: bottomNav(context),
    );
  }

  /// ================= MARKER =================
  Widget chargerMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: const Icon(Icons.ev_station, color: Colors.white, size: 24),
    );
  }

  /// ================= STATIONS CONTAINER =================
  Widget stationsContainer() {
    return Container(

      
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        filterChip("All", true),
        const SizedBox(width: 8),
        filterChip("Favorites", false),
      ],
    ),
  ],
),


          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, index) => stationCard(items[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.purple[300] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }

  /// ================= STATION CARD =================
  Widget stationCard(EvModel item) {
    final power = item.plugs?.isNotEmpty == true
        ? powerValues.reverse[item.plugs!.first.power]
        : "N/A";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Available",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),

          const SizedBox(height: 6),
          Text("⚡ $power"),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              amenitiesRow(item),
              ElevatedButton(
                onPressed: () {
                  // showModalBottomSheet(
                  //   context: context,
                  //   isScrollControlled: true,
                  //   builder: (_) => BookingsPage(stationId: item.id),
                  // );
                },
                child: const Text("Book Now"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= AMENITIES =================
  Widget amenitiesRow(EvModel item) {
    return Row(
      children: [
        if (item.amenities?.contains(Amenity.FOOD) ?? false)
          const Icon(Icons.restaurant, size: 18),
        if (item.amenities?.contains(Amenity.WIFI) ?? false)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.wifi, size: 18),
          ),
        if (item.amenities?.contains(Amenity.PARKING) ?? false)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.local_parking, size: 18),
          ),
      ],
    );
  }

  /// ================= STATIC NAV BAR =================
Widget bottomNav(BuildContext context) {
  return BottomNavigationBar(
    currentIndex: 0,
    type: BottomNavigationBarType.fixed,
    onTap: (index) {
      if (index == 3) {
        Navigator.pushNamed(
          context,
          '/mystation',
          arguments: Session.token,
        );
      }
      if (index == 4) {
        Navigator.pushNamed(
          context,
          '/manager',
          arguments: Session.token,
        );
      }
    },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.list), label: "Bookings"),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ],
  );
}

}

/// ================= TILE LAYER =================
TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.evera.app',
);
