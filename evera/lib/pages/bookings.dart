import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/bottom_nav.dart'; // Use your imported bottom_nav
import '../services/bookingservice.dart';
import 'package:intl/intl.dart';
import '../models/evmodel.dart';
import '../services/station_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'bookingpage.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List upcoming = [];
  List past = [];
  bool loading = true;

  LatLng? userLocation;
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  bool showRoute = false;

  @override
  void initState() {
    super.initState();
    loadBookings();
    getUserLocation();
  }

  /// ================= LOAD BOOKINGS =================
  Future<void> loadBookings() async {
    try {
      final data = await BookingService().getUserBookings();
      final now = DateTime.now();

      List up = [];
      List pa = [];

      for (var b in data) {
        final end = DateTime.parse(b['endDateTime']);

        if (b['status'] == "cancelled") {
          pa.add(b);
        } else if (end.isAfter(now)) {
          up.add(b);
        } else {
          pa.add(b);
        }
      }

      setState(() {
        upcoming = up;
        past = pa;
        loading = false;
      });
    } catch (e) {
      print("Load bookings error: $e");
      setState(() => loading = false);
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
  }

  /// ================= OPEN STATION DETAILS =================
  Future<void> openStationDetails(String stationId) async {
    try {
      final data = await StationService().getStationById(stationId);
      final station = EvModel.fromJson(data);

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
                  child: stationDetailContent(station),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      print("Error loading station: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings (${upcoming.length + past.length})"),
      ),
      bottomNavigationBar: bottomNav(
        context,
        2, // Bookings page index
        userLocation: userLocation,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("UPCOMING", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ...upcoming.map(
            (b) => bookingCard(
              bookingId: b['_id'],
              stationId: b['station']['_id'],
              station: b['station']['name'],
              distance: "N/A",
              date: DateFormat(
                'MMM d, yyyy',
              ).format(DateTime.parse(b['startDateTime'])),
              time:
                  "${DateFormat.jm().format(DateTime.parse(b['startDateTime']))} - ${DateFormat.jm().format(DateTime.parse(b['endDateTime']))}",
              power: b['plug'],
              price: "Rs ${b['price']}",
              status: b['status'],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "PAST BOOKINGS",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...past.map(
            (b) => bookingCard(
              bookingId: b['_id'],
              stationId: b['station']['_id'],
              station: b['station']['name'],
              distance: "N/A",
              date: DateFormat(
                'MMM d, yyyy',
              ).format(DateTime.parse(b['startDateTime'])),
              power: b['plug'],
              status: b['status'],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= BOOKING CARD =================
  Widget bookingCard({
    String? bookingId,
    String? stationId,
    required String station,
    required String distance,
    required String date,
    String? time,
    String? power,
    String? price,
    required String status,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    station,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(status),
                  backgroundColor: status == "pending" || status == "confirmed"
                      ? Colors.green[100]
                      : status == "cancelled"
                      ? Colors.red[100]
                      : Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("$distance • $date"),
            if (time != null) Text(time),
            if (power != null) Text(power),
            if (price != null)
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (status != "cancelled" && stationId != null && time != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => openStationDetails(stationId),
                  child: const Text("View Details"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ================= STATION DETAIL CONTENT =================
  Widget stationDetailContent(EvModel item) {
    final imageUrl = item.images.isNotEmpty ? item.images.first : null;
    final isAvailable = item.availableSlots > 0 && item.isOperational;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.price,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(item.address, style: const TextStyle(fontSize: 14)),
        Text(
          "${item.city}, ${item.province.isEmpty ? 'N/A' : item.province}",
          style: const TextStyle(fontSize: 14),
        ),
        if (item.telephone.isNotEmpty)
          Text("Tel: ${item.telephone}", style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        const Text(
          "Charging Plugs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        item.plugs.isEmpty
            ? const Text("No plugs available")
            : Wrap(
                spacing: 10,
                children: item.plugs
                    .map(
                      (p) => Chip(
                        label: Text("${p.plug} • ${p.power} • ${p.type}"),
                        backgroundColor: Colors.green[100],
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        item.amenities.isEmpty
            ? const Text("No amenities available")
            : Wrap(
                spacing: 10,
                runSpacing: 6,
                children: item.amenities
                    .map(
                      (a) => Chip(
                        label: Text(a),
                        backgroundColor: Colors.grey[200],
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isAvailable
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(station: item),
                      ),
                    ).then((_) => loadBookings());
                  }
                : null,
            child: const Text("Book Now"),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text("Directions"),
            onPressed: () {
              Navigator.pop(context); // close sheet
              getRoute(LatLng(item.latitude, item.longitude));
            },
          ),
        ),
      ],
    );
  }

  /// ================= GET ROUTE =================
  Future<void> getRoute(LatLng destination) async {
    if (userLocation == null) return;

    final start = "${userLocation!.longitude},${userLocation!.latitude}";
    final end = "${destination.longitude},${destination.latitude}";
    final url =
        "https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
        showRoute = true;
      });
    }
  }
}
