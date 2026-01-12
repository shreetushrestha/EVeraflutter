import 'package:flutter/material.dart';
import '../services/station_service.dart';
import '../services/session.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});
  

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  late StationService stationService;

  List<Map<String, dynamic>> allStations = [];
  List<Map<String, dynamic>> myStations = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Accept token passed via route arguments (if any) or use Session
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      // populate Session so StationService can pick it up
      Session.token = args;
    }

    if (!Session.isLoggedIn) {
      setState(() {
        errorMessage = 'Missing authentication token';
        isLoading = false;
      });
      return;
    }

    stationService = StationService();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      final all = await stationService.getAllStations();

      List<Map<String, dynamic>> mine = [];
      try {
        mine = await stationService.getMyStations();
      } catch (_) {
        // User might not be manager – ignore
      }

      setState(() {
        allStations = all;
        myStations = mine;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charging Stations'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: fetchStations,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 🔹 ALL STATIONS
                        const Text(
                          'All Stations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...allStations
                            .map((station) =>
                                StationCard(station: station))
                            .toList(),

                        const SizedBox(height: 30),

                        /// 🔹 MY STATIONS
                        if (myStations.isNotEmpty) ...[
                          const Text(
                            'My Stations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...myStations
                              .map((station) =>
                                  StationCard(station: station))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
class StationCard extends StatelessWidget {
  final Map<String, dynamic> station;

  const StationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station['name'] ?? 'Unnamed Station',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("📍 ${station['city'] ?? 'N/A'}"),
            Text("📞 ${station['telephone'] ?? 'N/A'}"),
            const SizedBox(height: 6),
            Text(
              "Slots: ${station['availableSlots'] ?? 0} / ${station['totalSlots'] ?? 0}",
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// class StationsPage extends StatelessWidget {
//   const StationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Stations Page'),
//       ),
//       body: const Center(
//         child: Text('Stations Page Content Here'),
//       ),
//     );
//   }
// }

