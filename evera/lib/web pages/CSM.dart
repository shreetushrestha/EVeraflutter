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

  // ================= DASHBOARD CARD =================

  Widget dashboardCard(Map s) {
    final double utilization =
        (s['totalSlots'] - s['availableSlots']) / s['totalSlots'];

    final plugs =
        (s['plugs'] as List<dynamic>).cast<Map<String, dynamic>>();

    bool isOperational = s['isOperational'] ?? true;

    String? imageUrl =
        (s['images'] != null && s['images'].isNotEmpty)
            ? s['images'][0]
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// COVER IMAGE
          if (imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  s['name'],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  "${s['city']} • ${s['address']}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                /// STATUS + SLOTS
                Row(
                  children: [
                    statusBadge(s),
                    const SizedBox(width: 10),
                    Text(
                      "Slots: ${s['availableSlots']} / ${s['totalSlots']}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// ===== OPERATIONAL CONTROL (MATCH IMAGE STYLE) =====
                const Text(
                  "Availability",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [

                    /// AVAILABLE BUTTON
                    GestureDetector(
                      onTap: () async {
                        if (!isOperational) {
                          await StationService()
                              .toggleOperational(s['_id'], true);
                          fetchStations();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: isOperational
                              ? const Color(0xff5fb989)
                              : const Color(0xffe0e0e0),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Available",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isOperational
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// UNAVAILABLE BUTTON
                    GestureDetector(
                      onTap: () async {
                        if (isOperational) {
                          await StationService()
                              .toggleOperational(s['_id'], false);
                          fetchStations();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: !isOperational
                              ? const Color(0xffd96b6b)
                              : const Color(0xffe0e0e0),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Unavailable",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !isOperational
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// UTILIZATION
                const Text(
                  "Utilization",
                  style:
                      TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: utilization,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                            Colors.green),
                  ),
                ),

                const SizedBox(height: 22),

                /// STATS
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    statCard(
                        "Available",
                        s['availableSlots']
                            .toString(),
                        Colors.green),
                    statCard(
                        "Total",
                        s['totalSlots']
                            .toString(),
                        Colors.purple),
                  ],
                ),

                const SizedBox(height: 22),

                /// PLUGS
                const Text(
                  "Charger Management",
                  style:
                      TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: plugs
                      .map(
                        (p) => infoChip(
                          "${p['plug']} • ${p['power']} • ${p['type']}",
                          Icons.electrical_services,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget statusBadge(Map s) {
    bool available = s['availableSlots'] > 0;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available
            ? Colors.green[100]
            : Colors.red[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        available ? "Available" : "Full",
        style: TextStyle(
          fontSize: 12,
          color: available
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget statCard(
      String title, String value, Color color) {
    return Container(
      width:
          MediaQuery.of(context).size.width * 0.22,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
                fontSize: 11,
                color:
                    Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget infoChip(
      String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor:
          Colors.grey.shade100,
    );
  }
}
