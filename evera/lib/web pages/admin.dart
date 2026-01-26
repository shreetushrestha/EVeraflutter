
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topHeader(),
                  const SizedBox(height: 20),
                  _statsCards(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        _mapSection(),
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
          _SideIcon(icon: Icons.list_alt, label: 'Bookings'),
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
          "Hello Admin!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(radius: 22, backgroundColor: Colors.grey),
      ],
    );
  }

  // ================= STATS =================
  Widget _statsCards() {
    return Row(
      children: const [
        _StatCard(title: 'Charging Stations', value: '134', color: Color(0xFFD8C4FF)),
        SizedBox(width: 16),
        _StatCard(title: 'Chargers', value: '370', color: Color(0xFFCFF0DD)),
        SizedBox(width: 16),
        _StatCard(title: 'Active Stations', value: '134', color: Color(0xFFD8C4FF)),
      ],
    );
  }

  // ================= MAP =================
  Widget _mapSection() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Map View (Flutter Map / Google Map)'),
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
              child: ListView(
                children: const [
                  _StationCard(),
                  _StationCard(),
                  _StationCard(),
                ],
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

  const _SideIcon({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white70),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

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
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard();

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
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NEA Charging Station', style: TextStyle(fontWeight: FontWeight.bold)),
              Chip(label: Text('Available')),
            ],
          ),
          SizedBox(height: 6),
          Text('0.5 km • 150kW DC Fast'),
          SizedBox(height: 8),
          Text('Food • WiFi • Parking', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
