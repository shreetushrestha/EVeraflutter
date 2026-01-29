import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/evmodel.dart';
import 'dart:convert';

import 'package:evera/pages/bookings.dart';
import 'package:evera/pages/search.dart';
import 'package:evera/pages/profile.dart';

import '../services/station_service.dart';
import '../services/session.dart';

/// ================= HOME PAGE =================
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapController _mapController = MapController();

  List<EvModel> items = [];
  LatLng? userLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStations();
    getUserLocation();
  }

  Future<void> fetchStations() async {
    try {
      final rawStations = await StationService().getAllStations();

      setState(() {
        items = rawStations.map<EvModel>((e) {
          return EvModel.fromJson(e);
        }).toList();

        isLoading = false;
      });
    } catch (e, s) {
      debugPrint("Station fetch error: $e");
      debugPrintStack(stackTrace: s);
      setState(() => isLoading = false);
    }
  }

  /// ================= USER LOCATION =================
  Future<void> getUserLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

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
    _mapController.move(userLocation!, 14);
  }

  String getPlugText(List<Plug> plugs) {
    if (plugs.isEmpty) return "N/A";

    return plugs.map((p) => "${p.plug} - ${p.power} - ${p.type}").join(", ");
  }

  void openStationOverlay(EvModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: stationDetailContent(item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ================= MAP =================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(28.20833, 83.95804),
              initialZoom: 13,
            ),
            children: [
              openStreetMapTileLayer,

              /// USER MARKER
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 24,
                      height: 24,
                      point: userLocation!,
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

              /// STATION MARKERS
              MarkerLayer(
                markers: items.map((item) {
                  return Marker(
                    width: 46,
                    height: 46,
                    point: LatLng(item.latitude, item.longitude),
                    child: chargerMarker(),
                  );
                }).toList(),
              ),
            ],
          ),

          /// ================= STATION LIST =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: stationsContainer(),
          ),
        ],
      ),

      /// ================= NAV BAR =================
      bottomNavigationBar: bottomNav(context, 0),
    );
  }

  /// ================= MARKER ICON =================
  Widget chargerMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: const Icon(Icons.ev_station, color: Colors.white),
    );
  }

  /// ================= STATION CONTAINER =================
  Widget stationsContainer() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // shrink-wrap the column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips row
          Row(
            children: [
              filterChip("All", true),
              const SizedBox(width: 8),
              filterChip("Favorites", false),
            ],
          ),

          const SizedBox(height: 6), // tiny gap
          // Station cards
          Flexible(
            child: ListView.separated(
              shrinkWrap: true, // make list view take only necessary height
              physics: const ClampingScrollPhysics(), // no extra bounce
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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

  Widget stationCard(EvModel item) {
    final plug = getPlugText(item.plugs);

    return GestureDetector(
      onTap: () => openStationOverlay(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                statusBadge(),
              ],
            ),

            const SizedBox(height: 6),
            Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text("⚡ $plug"),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                amenitiesRow(item),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "Available",
        style: TextStyle(color: Colors.green, fontSize: 12),
      ),
    );
  }

  /// ================= AMENITIES =================
  Widget amenitiesRow(EvModel item) {
    return Row(
      children: [
        if (item.amenities.any((a) => a.toLowerCase().contains('food')))
          const Icon(Icons.restaurant, size: 18),
        if (item.amenities.any((a) => a.toLowerCase().contains('wifi')))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.wifi, size: 18),
          ),
        if (item.amenities.any((a) => a.toLowerCase().contains('parking')))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.local_parking, size: 18),
          ),
      ],
    );
  }

  /// ================= NAV BAR =================
  Widget bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BookingsPage()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  Widget stationDetailContent(EvModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HANDLE
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        /// NAME + STATUS
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            statusBadge(),
          ],
        ),

        const SizedBox(height: 12),

        /// LOCATION INFO
        infoRow(Icons.location_on, item.address),
        infoRow(
          Icons.location_city,
          "${item.city}, ${item.province.isEmpty ? 'N/A' : item.province}",
        ),

        if (item.telephone.isNotEmpty) infoRow(Icons.phone, item.telephone),

        const SizedBox(height: 16),

        const Text(
          "Charging Plugs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),

        item.plugs.isEmpty
            ? const Text("No plugs available")
            : Wrap(
                spacing: 10,
                children: item.plugs.map((p) {
                  return Chip(
                    label: Text("${p.plug} • ${p.power} • ${p.type}"),
                    backgroundColor: Colors.green[100],
                  );
                }).toList(),
              ),
        const SizedBox(height: 16),

        /// TYPE
        const Text(
          "Station Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: item.type
              .map(
                (t) => Chip(label: Text(t), backgroundColor: Colors.blue[100]),
              )
              .toList(),
        ),

        const SizedBox(height: 16),

        /// AMENITIES
        const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),

        item.amenities.isEmpty
            ? const Text("No amenities available")
            : Wrap(
                spacing: 10,
                runSpacing: 6,
                children: item.amenities.map((a) {
                  return Chip(
                    label: Text(a),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),

        const SizedBox(height: 16),

        /// COORDINATES
        const Text(
          "Coordinates",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text("Latitude: ${item.latitude}"),
        Text("Longitude: ${item.longitude}"),

        const SizedBox(height: 24),

        /// BOOK BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Book Now"),
          ),
        ),
      ],
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// ================= TILE LAYER =================
TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.evera.app',
);
