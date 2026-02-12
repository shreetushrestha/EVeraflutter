import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/bookingservice.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List upcoming = [];
  List past = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

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

  Future<void> cancelBooking(String id) async {
    final success = await BookingService().cancelBooking(id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled")),
      );
      loadBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cancel failed")),
      );
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
      bottomNavigationBar: bottomNav(context, 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("UPCOMING",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ...upcoming.map(
            (b) => bookingCard(
              bookingId: b['_id'],
              station: b['station']['name'],
              distance: "N/A",
              date: DateFormat('MMM d, yyyy')
                  .format(DateTime.parse(b['startDateTime'])),
              time:
                  "${DateFormat.jm().format(DateTime.parse(b['startDateTime']))} - ${DateFormat.jm().format(DateTime.parse(b['endDateTime']))}",
              power: b['plug'],
              price: "Rs ${b['price']}",
              status: b['status'],
            ),
          ),

          const SizedBox(height: 20),

          const Text("PAST BOOKINGS",
              style: TextStyle(fontWeight: FontWeight.bold)),

          ...past.map(
            (b) => bookingCard(
              bookingId: b['_id'],
              station: b['station']['name'],
              distance: "N/A",
              date: DateFormat('MMM d, yyyy')
                  .format(DateTime.parse(b['startDateTime'])),
              power: b['plug'],
              status: b['status'],
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingCard({
    String? bookingId,
    required String station,
    required String distance,
    required String date,
    String? time,
    String? power,
    String? price,
    required String status,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
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
                    style:
                        const TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(status),
                  backgroundColor: status == "pending" ||
                          status == "confirmed"
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
              Text(price,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold)),

            if (status != "cancelled" && time != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("View Details"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (bookingId != null) {
                          cancelBooking(bookingId);
                        }
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
