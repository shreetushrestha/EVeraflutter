import 'package:flutter/material.dart';
import '../models/evmodel.dart';
import '../services/station_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<EvModel> stations = [];
  bool isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final rawStations = await StationService().getAllStations();

      setState(() {
        stations = rawStations
            .map<EvModel>((e) => EvModel.fromJson(e))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Admin station fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  void _showStationInfo(EvModel station) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(station.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Address: ${station.address}"),
              const SizedBox(height: 6),
              Text("City: ${station.city}"),
              const SizedBox(height: 6),
              Text("Price: ${station.price}"),
              const SizedBox(height: 6),
              Text("Chargers: ${station.plugs.length}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          _sideBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _topHeader(),
                        const SizedBox(height: 20),
                        _statsCards(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: [
                              _mapView(),
                              const SizedBox(width: 20),
                              _stationList(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================
  Widget _sideBar() {
    return Container(
      width: 90,
      color: const Color(0xFF7AC89C),
      child: Column(
        children: const [
          SizedBox(height: 30),
          Icon(Icons.flash_on, color: Colors.white, size: 36),
          SizedBox(height: 40),
          _SideIcon(icon: Icons.home, label: 'Home', active: true),
          _SideIcon(icon: Icons.search, label: 'Search'),
          _SideIcon(icon: Icons.settings, label: 'Settings'),
          _SideIcon(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _topHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Admin Dashboard",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(radius: 22, backgroundColor: Colors.grey),
      ],
    );
  }

  // ================= STATS =================
  Widget _statsCards() {
    return Row(
      children: [
        _StatCard(
          title: 'Charging Stations',
          value: stations.length.toString(),
          color: const Color(0xFFD8C4FF),
        ),
        const SizedBox(width: 16),
        _StatCard(
          title: 'Total Chargers',
          value: _calculateTotalPlugs().toString(),
          color: const Color(0xFFCFF0DD),
        ),
      ],
    );
  }

  int _calculateTotalPlugs() {
    int total = 0;
    for (var station in stations) {
      total += station.plugs.length;
    }
    return total;
  }

  // ================= MAP PLACEHOLDER =================
  Widget _mapView() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(28.20833, 83.95804),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.evera.app',
              ),

              /// STATION MARKERS
              MarkerLayer(
                markers: stations.map((station) {
                  return Marker(
                    width: 44,
                    height: 44,
                    point: LatLng(station.latitude, station.longitude),
                    child: GestureDetector(
                      onTap: () => _showStationInfo(station),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(
                          Icons.ev_station,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STATION LIST =================
  Widget _stationList() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Charging Stations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: stations.length,
                itemBuilder: (_, index) =>
                    _StationCard(station: stations[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= COMPONENTS =================

class _SideIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _SideIcon({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final EvModel station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(station.address),
          const SizedBox(height: 6),
          Text("City: ${station.city}"),
          const SizedBox(height: 6),
          Text("Chargers: ${station.plugs.length}"),
          const SizedBox(height: 6),
          Text(
            "Price: ${station.price}",
            style: const TextStyle(color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
