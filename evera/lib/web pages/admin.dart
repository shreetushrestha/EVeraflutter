import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/station_service.dart';
import './loginweb.dart';

// 🔴 Make sure this exists
import './sidebar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final StationService _stationService = StationService();

  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    final data = await _stationService.getAllStations();
    if (!mounted) return;
    setState(() {
      stations = data;
      isLoading = false;
    });
  }

  int get totalChargers {
    int total = 0;
    for (final s in stations) {
      if (s['plugs'] is List) {
        total += (s['plugs'] as List).length;
      }
    }
    return total;
  }

  int get operationalStations =>
      stations.where((s) => s['isOperational'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                AdminSidebar(selectedIndex: 0, onHomeTap: () {}),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // HEADER
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dashboard",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Welcome back! Here's what's happening today.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // 👤 Avatar
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF67C090),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // 👤 Name (optional)
                                const Text(
                                  "Admin",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),

                                const SizedBox(width: 14),

                                // 🚪 Logout
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const WebManagerLogin(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Logout",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // STATS
                        Row(
                          children: [
                            _statCard(
                              icon: Icons.location_on,
                              title: "Total Stations",
                              value: stations.length.toString(),
                              color: Colors.green,
                            ),
                            _statCard(
                              icon: Icons.flash_on,
                              title: "Active Chargers",
                              value: totalChargers.toString(),
                              color: Colors.pink,
                            ),
                            _statCard(
                              icon: Icons.people,
                              title: "Operational",
                              value: operationalStations.toString(),
                              color: Colors.purple,
                            ),
                            _statCard(
                              icon: Icons.timer,
                              title: "Avg. Session",
                              value: "45 min",
                              color: Colors.orange,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // MAIN CONTENT
                        Expanded(
                          child: Row(
                            children: [
                              // MAP
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: const LatLng(28.2, 83.9),
                                        initialZoom: 12,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        ),
                                        MarkerLayer(
                                          markers: stations.map((s) {
                                            return Marker(
                                              point: LatLng(
                                                (s['latitude'] ?? 0).toDouble(),
                                                (s['longitude'] ?? 0)
                                                    .toDouble(),
                                              ),
                                              width: 40,
                                              height: 40,
                                              child: const Icon(
                                                Icons.ev_station,
                                                color: Color(0xFF67C090),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              // RIGHT PANEL
                              Expanded(
                                child: Column(
                                  children: [
                                    _quickAction(
                                      icon: Icons.add,
                                      title: "Add New Station",
                                      subtitle: "Create a charging point",
                                      color: const Color(0xFF67C090),
                                    ),
                                    _quickAction(
                                      icon: Icons.bar_chart,
                                      title: "View Reports",
                                      subtitle: "Analytics & insights",
                                      color: Color(0xFFC06797),
                                    ),
                                    _quickAction(
                                      icon: Icons.map,
                                      title: "Map View",
                                      subtitle: "See all locations",
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
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

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
