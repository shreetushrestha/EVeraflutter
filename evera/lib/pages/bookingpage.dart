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
  final Color primary = const Color(0xFFC06797);

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
    if (priceStr.isNotEmpty) {
      pricePerHour = int.parse(priceStr);
    }
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
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking Failed")));
    }
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
    final timeText = selectedTime.format(context);

    final imageUrl = widget.station.images.isNotEmpty
        ? widget.station.images.first
        : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Book Charging Slot"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// STATION IMAGE
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            /// STATION NAME
            Text(
              widget.station.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              widget.station.address,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// DATE TIME
            sectionCard(
              child: InkWell(
                onTap: pickDateTime,
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 10),
                    Text("$dateText  •  $timeText"),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),

            /// DURATION TITLE
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Charging Duration",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            /// DURATION SELECTOR
            Wrap(
              spacing: 10,
              children: <double>[1, 2, 3, 4].map((d) {
                final selected = selectedDuration == d;

                return ChoiceChip(
                  label: Text("${d.toInt()} hr"),
                  selected: selected,
                  selectedColor: primary,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedDuration = d;
                      calculateTotalPrice();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            /// PRICE CARD
            sectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Price", style: TextStyle(fontSize: 16)),
                  Text(
                    "Rs ${totalPrice.toInt()}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ESEWA PAYMENT
            SizedBox(
              width: double.infinity,
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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(
                          0.1,
                        ), // 👈 10% dim background
                        builder: (context) {
                          return Center(
                            // 👈 force exact center
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              title: Row(
                                children: [
                                  Icon(Icons.check_circle, color: primary),
                                  const SizedBox(width: 8),
                                  const Text("Success"),
                                ],
                              ),
                              content: const Text(
                                "Your booking has been confirmed successfully.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // close dialog
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        },
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
          ],
        ),
      ),
    );
  }
}
