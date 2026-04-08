import 'package:flutter/material.dart';
import './manage_stations.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onHomeTap;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: const Color(0xFF67C090),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // 🔋 Logo + Name
          const Icon(Icons.flash_on, color: Colors.white, size: 32),
          const SizedBox(height: 6),
          const Text(
            "EVera",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          // 🏠 Home
          _navItem(
            icon: Icons.home,
            label: "Home",
            isSelected: selectedIndex == 0,
            onTap: onHomeTap,
          ),

          const SizedBox(height: 20),

          // ⚡ Manage Stations
          _navItem(
            icon: Icons.ev_station,
            label: "Manage",
            isSelected: selectedIndex == 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageStationsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF67C090) : Colors.white,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF67C090) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
