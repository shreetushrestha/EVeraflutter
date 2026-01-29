import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings (10)")),
      bottomNavigationBar: bottomNav(context, 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("UPCOMING", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          bookingCard(
            station: "NEA Charging Station",
            distance: "0.5 km",
            date: "Nov 2, 2025",
            time: "10:00 AM - 12:00 PM",
            power: "150kW DC Fast",
            price: "Rs 120",
            status: "upcoming",
          ),

          const SizedBox(height: 20),
          const Text("PAST BOOKINGS", style: TextStyle(fontWeight: FontWeight.bold)),
          bookingCard(
            station: "UltraFast Hub",
            distance: "2.5 km",
            date: "Oct 28, 2025",
            power: "200kW DC Ultra",
            status: "completed",
          ),
        ],
      ),
    );
  }

  Widget bookingCard({
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(station, style: const TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(status),
                  backgroundColor: status == "upcoming" ? Colors.green[100] : Colors.grey[300],
                )
              ],
            ),
            const SizedBox(height: 6),
            Text("$distance • $date"),
            if (time != null) Text(time),
            if (power != null) Text(power),
            if (price != null) Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (status == "upcoming")
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () {}, child: const Text("View Details"))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
