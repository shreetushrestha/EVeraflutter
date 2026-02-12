import 'package:flutter/material.dart';
import '../models/evmodel.dart';
import '../services/bookingservice.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'esewa_service.dart';

class BookingPage extends StatefulWidget {
  final EvModel station;
  const BookingPage({super.key, required this.station});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primary = const Color(0xFF67C090);
  final Color secondary = const Color(0xFFC06797);

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  double selectedDuration = 1;
  int pricePerHour = 15;
  double totalPrice = 0;
  String userMobile = "";

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
    totalPrice = selectedDuration * pricePerHour;
    setState(() {});
  }

  Future<void> fetchUserInfo() async {
    final userId = Session.userId;
    if (userId == null) return;

    final userResp = await AuthService().getUserById(userId);
    if (userResp != null && userResp.statusCode == 200) {
      setState(() {
        userMobile = userResp.data['phone'] ?? "";
      });
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time == null) return;

    setState(() {
      selectedDate = date;
      selectedTime = time;
    });
  }

  Future<void> confirmBooking() async {
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking Confirmed")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking Failed")));
    }
  }

  Widget infoCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: secondary),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    final timeText = selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Book Station"),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.station.images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  widget.station.images.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.station.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            infoCard(
              icon: Icons.location_on,
              title: "${widget.station.city}, ${widget.station.province}",
            ),
            const SizedBox(height: 10),
            infoCard(
              icon: Icons.electric_car,
              title: widget.station.plugs.map((p) => p.plug).join(", "),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickDateTime,
              child: infoCard(
                icon: Icons.access_time,
                title: "$dateText  •  $timeText",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Duration",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: <double>[0.5, 1, 2, 3].map((d) {
                final isSelected = selectedDuration == d;

                return ChoiceChip(
                  label: Text(d == 0.5 ? "30 min" : "${d.toInt()} hr"),
                  selected: isSelected,
                  selectedColor: secondary,
                  onSelected: (_) {
                    selectedDuration = d;
                    calculateTotalPrice();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Price: Rs ${totalPrice.toInt()}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondary,
              ),
            ),
            const SizedBox(height: 24),

            // Row of Confirm Booking & eSewa Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: confirmBooking,
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
  child: SizedBox(
    height: 52,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: () {
        EsewaService.pay(
          amount: totalPrice.toInt(),
          productName: "EV Station Booking",
          onSuccess: () async {
            // Only confirm booking if payment succeeds
            await confirmBooking();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment Successful & Booking Confirmed")),
            );
          },
          onFailure: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment Failed")),
            );
          },
        );
      },
      child: const Text(
        "Pay with eSewa",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
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
