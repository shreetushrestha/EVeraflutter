import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'manage_stations.dart';

import '../services/session.dart';
import '../services/station_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      AdminOverviewTab(
        profileKey: _profileKey,
        onOpenProfileMenu: _showProfileMenu,
      ),
      const ManageStationsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SafeArea(
        child: Row(
          children: [
            _sidebar(),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  /// ================= SIDEBAR =================
  Widget _sidebar() {
    return Container(
      width: 230,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),

          /// LOGO
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFF67C090),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "EVera Admin",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          _navItem(Icons.dashboard, "Dashboard", 0),
          _navItem(Icons.ev_station, "Manage Stations", 1),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Admin Panel",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF67C090).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF67C090)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF67C090)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= PROFILE MENU =================
  Future<void> _showProfileMenu() async {
    final RenderBox box =
        _profileKey.currentContext!.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(_profileKey.currentContext!).context.findRenderObject()
            as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      items: [
        const PopupMenuItem(
          enabled: false,
          child: Text(
            "Admin Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: "logout",
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Logout", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result == "logout") {
      Session.token = null;
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }
}

/// ================= OVERVIEW =================
class AdminOverviewTab extends StatefulWidget {
  final GlobalKey profileKey;
  final VoidCallback onOpenProfileMenu;

  const AdminOverviewTab({
    super.key,
    required this.profileKey,
    required this.onOpenProfileMenu,
  });

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
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

  /// ✅ FIXED
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Admin Dashboard",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                key: widget.profileKey,
                onTap: widget.onOpenProfileMenu,
                child: const CircleAvatar(
                  backgroundColor: Color(0xffe8f5e9),
                  child: Icon(Icons.person, color: Color(0xFF67C090)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      _stat("Stations", stations.length.toString()),
                      _stat("Chargers", totalChargers.toString()),
                      _stat("Operational", operationalStations.toString()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(child: _map()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
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

  Widget _map() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(28.2, 83.9),
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: stations.map((s) {
            return Marker(
              point: LatLng(
                (s['latitude'] ?? 0).toDouble(),
                (s['longitude'] ?? 0).toDouble(),
              ),
              width: 40,
              height: 40,
              child: const Icon(Icons.ev_station, color: Color(0xFF67C090)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
