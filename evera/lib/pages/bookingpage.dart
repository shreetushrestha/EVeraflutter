import 'package:flutter/material.dart';
import '../models/evmodel.dart';
import '../services/bookingservice.dart';
import '../services/auth_service.dart'; // to fetch user info
import '../services/session.dart';

class BookingPage extends StatefulWidget {
  final EvModel station;
  const BookingPage({super.key, required this.station});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  double selectedDuration = 1; // default 1 hour
  int pricePerHour = 15;
  double totalPrice = 0;
  String userMobile = ""; // fetch from backend

  @override
  void initState() {
    super.initState();
    parseStationPrice();
    calculateTotalPrice();
    fetchUserInfo();
  }

  void parseStationPrice() {
    final priceStr = widget.station.price.replaceAll(RegExp(r'[^0-9]'), '');
    if (priceStr.isNotEmpty) pricePerHour = int.parse(priceStr);
  }

  void calculateTotalPrice() {
    setState(() {
      totalPrice = selectedDuration * pricePerHour;
    });
  }

  Future<void> fetchUserInfo() async {
    final userId = Session.userId;
    if (userId == null) {
      setState(() {
        userMobile = "<default-mobile>";
      });
      return;
    }
    final userResp = await AuthService().getUserById(userId);
    if (userResp != null && userResp.statusCode == 200) {
      setState(() {
        userMobile = userResp.data['phone'] ?? "<default-mobile>";
      });
    } else {
      setState(() {
        userMobile = "<default-mobile>";
      });
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

Future<void> confirmBooking() async {
  if (selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select start time")),
    );
    return;
  }

  final startDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime!.hour,
    selectedTime!.minute,
  );

  try {
    await BookingService().createBooking(
      stationId: widget.station.id,
      plug: widget.station.plugs.isNotEmpty
          ? widget.station.plugs.first.plug
          : "",
      startDateTime: startDateTime,
      duration: selectedDuration,
      price: totalPrice.toInt(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking confirmed!")),
    );

    Navigator.pop(context);
  } catch (e) {
    print("Booking failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking failed")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Station"),
        backgroundColor: Colors.purple[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.station.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.station.images.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(widget.station.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Price per hour: Rs. $pricePerHour",
                style: const TextStyle(fontSize: 16, color: Colors.orange)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                ElevatedButton(
                  onPressed: pickDate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300]),
                  child: const Text("Select"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedTime != null
                    ? "Time: ${selectedTime!.format(context)}"
                    : "Select start time"),
                ElevatedButton(
                  onPressed: pickTime,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300]),
                  child: const Text("Select"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Select Duration:"),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [0.5, 1, 2, 3].map((d) {
                final label = d == 0.5 ? "30 min" : "${d.toInt()} hr";
                final isSelected = selectedDuration == d;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedDuration = d.toDouble());
                    calculateTotalPrice();
                  },
                  selectedColor: Colors.purple[300],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text("Total Price: Rs. ${totalPrice.toInt()}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: confirmBooking,
                child: const Text("Confirm Booking"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
