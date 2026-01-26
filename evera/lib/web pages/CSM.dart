import 'package:flutter/material.dart';
import '../services/station_service.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  bool loading = true;
  List stations = [];

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final data = await StationService().getMyStations();
      setState(() {
        stations = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : stations.isEmpty
                ? const Center(child: Text("No station found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      return dashboardCard(stations[index]);
                    },
                  ),
      ),
    );
  }

  /// ================= STATION DASHBOARD =================

  Widget dashboardCard(Map s) {
    final double utilization =
        (s['totalSlots'] - s['availableSlots']) / s['totalSlots'];

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ========== TOP PROFILE ==========
          Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("${s['city']} • ${s['address']}",
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        statusBadge(s),
                        const SizedBox(width: 10),
                        Text(
                          "Slots: ${s['availableSlots']} / ${s['totalSlots']}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          /// ========== UTILIZATION BAR ==========
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Utilization",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: utilization,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// ========== STATS ==========
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              statCard("Active",
                  s['availableSlots'].toString(), Colors.green),
              statCard("Completed", "3", Colors.blue),
              statCard("Pending", "4", Colors.orange),
              statCard("Total",
                  s['totalSlots'].toString(), Colors.purple),
            ],
          ),

          const SizedBox(height: 22),

          /// ========== PLUG MANAGEMENT ==========
          const Text("Charger Management",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: s['plugs']
                .map<Widget>(
                  (p) => chargerControl(p),
                )
                .toList(),
          ),

          const SizedBox(height: 22),

          /// ========== FULL INFORMATION ==========
          const Text("Station Information",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          infoRow(Icons.phone, s['telephone']),
          infoRow(Icons.location_city, "Province: ${s['province']}"),
          infoRow(Icons.my_location,
              "Lat: ${s['latitude']}  |  Lng: ${s['longitude']}"),

          const SizedBox(height: 12),

          /// AMENITIES
          Wrap(
            spacing: 8,
            children: s['amenities']
                .map<Widget>(
                  (a) => infoChip(a, Icons.check_circle),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          /// PLUG TYPES
          Wrap(
            spacing: 8,
            children: s['plugs']
                .map<Widget>(
                  (p) => infoChip(p, Icons.electrical_services),
                )
                .toList(),
          ),

          const SizedBox(height: 20),

          /// ========== HISTORY ==========
          const Text("Charging History",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          historyTile("Shamir Maharjan", "Type 2"),
          historyTile("Shreetu Shrestha", "Type 2"),
          historyTile("Sunita Joshi", "Type 2"),
        ],
      ),
    );
  }

  /// ================= UI COMPONENTS =================

  Widget statusBadge(Map s) {
    bool available = s['availableSlots'] > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        available ? "Available" : "Full",
        style: TextStyle(
            fontSize: 12,
            color: available ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget statCard(String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.19,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget chargerControl(String type) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              controlButton("Available", true),
              controlButton("Unavailable", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget controlButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, color: active ? Colors.white : Colors.black),
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget infoChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget historyTile(String name, String charger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 18,
              child: Icon(Icons.person, size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500))),
          Text("Charger: $charger",
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
