import 'package:flutter/material.dart';
import '../services/station_service.dart';
import '../services/bookingservice.dart';
import 'loginweb.dart';
import 'package:intl/intl.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  bool loading = true;
  List stations = [];
  List bookings = [];
  String selectedFilter = 'All';

  bool isStationAvailable = true; // default state

  final Map<String, dynamic> managerData = {
    'name': 'hari',
    'email': 'hari@gmail.com',
    'role': 'Station Manager',
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([fetchStations(), fetchBookings()]);
    setState(() => loading = false);
  }

  Future<void> fetchStations() async {
    try {
      final data = await StationService().getMyStations();
      setState(() => stations = data);
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> fetchBookings() async {
    try {
      final data = await BookingService().getManagerBookings();
      setState(() => bookings = data);
    } catch (e) {
      debugPrint("Booking fetch error: $e");
    }
  }

  void toggleAvailability(bool available) {
    setState(() {
      isStationAvailable = available;
    });
  }

  // Stats getters
  int get totalBookings => bookings.length;
  int get activeNow => bookings
      .where((b) => b['status'] == 'active' || b['status'] == 'confirmed')
      .length;
  int get completed => bookings.where((b) => b['status'] == 'completed').length;
  double get todayRevenue {
    return bookings
        .where((b) => b['status'] != 'cancelled')
        .fold(
          0.0,
          (sum, b) =>
              sum + (double.tryParse(b['price']?.toString() ?? '0') ?? 0.0),
        );
  }

  List get filteredBookings {
    if (selectedFilter == 'All') return bookings;
    if (selectedFilter == 'Active')
      return bookings
          .where((b) => b['status'] == 'active' || b['status'] == 'confirmed')
          .toList();
    if (selectedFilter == 'Completed')
      return bookings.where((b) => b['status'] == 'completed').toList();
    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    buildStatsRow(),
                    const SizedBox(height: 20),
                    if (stations.isNotEmpty)
                      Expanded(child: buildMainContent(stations[0]))
                    else
                      const Center(child: Text("No station found")),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        // Left: Title
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Station Manager",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Manage your charging station and bookings.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        // Right: Avatar + name + logout
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF67C090),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  managerData['name'] ?? 'Manager',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  managerData['role'] ?? 'Station Manager',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 14),
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WebManagerLogin()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatsRow() {
    return Row(
      children: [
        _statCard(
          icon: Icons.calendar_today,
          title: "Total Bookings",
          value: totalBookings.toString(),
          color: Colors.green,
        ),
        _statCard(
          icon: Icons.check_circle_outline,
          title: "Active Now",
          value: activeNow.toString(),
          color: Colors.pink,
        ),
        _statCard(
          icon: Icons.done_outline,
          title: "Completed",
          value: completed.toString(),
          color: Colors.purple,
        ),
        _statCard(
          icon: Icons.attach_money,
          title: "Revenue",
          value: "Rs.${todayRevenue.toStringAsFixed(0)}",
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainContent(Map station) {
    final plugs = (station['plugs'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final amenities =
        (station['amenities'] as List<dynamic>?)?.cast<String>() ?? [];
    String? imageUrl =
        (station['images'] != null && station['images'].isNotEmpty)
        ? station['images'][0]
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT: Station Info
        Expanded(
          flex: 2,
          child: _buildStationCard(station, imageUrl, plugs, amenities),
        ),
        const SizedBox(width: 20),
        // RIGHT: Bookings
        Expanded(flex: 3, child: _buildBookingsCard()),
      ],
    );
  }

  Widget _buildStationCard(
    Map station,
    String? imageUrl,
    List plugs,
    List amenities,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with available badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.charging_station,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF67C090),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${station['availableSlots']}/${station['totalSlots']} Avail',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        station['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => openEditStationDialog(station),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on,
                  '${station['city']}, ${station['address']}',
                ),
                _buildInfoRow(Icons.phone, station['telephone'] ?? '-'),
                _buildInfoRow(Icons.attach_money, station['price'] ?? '-'),

                const SizedBox(height: 16),
                const Text(
                  'Plugs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: plugs.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        '${p['plug']} ${p['power']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),

                if (amenities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: amenities.map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          a,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Station Availability',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isStationAvailable
                              ? null
                              : () => toggleAvailability(true),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Available'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStationAvailable
                                ? Colors.green
                                : Colors.grey[200],
                            foregroundColor: isStationAvailable
                                ? Colors.white
                                : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !isStationAvailable
                              ? null
                              : () => toggleAvailability(false),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: const Text('Unavailable'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isStationAvailable
                                ? Colors.red
                                : Colors.grey[200],
                            foregroundColor: !isStationAvailable
                                ? Colors.white
                                : Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void openEditStationDialog(Map station) {
    final nameController = TextEditingController(text: station['name']);
    final cityController = TextEditingController(text: station['city']);
    final addressController = TextEditingController(text: station['address']);
    final priceController = TextEditingController(
      text: station['price']?.toString(),
    );
    final totalSlotsController = TextEditingController(
      text: station['totalSlots'].toString(),
    );
    final availableSlotsController = TextEditingController(
      text: station['availableSlots'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Station"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input(nameController, "Name"),
                _input(cityController, "City"),
                _input(addressController, "Address"),
                _input(priceController, "Price"),
                _input(totalSlotsController, "Total Slots"),
                _input(availableSlotsController, "Available Slots"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await StationService().updateStation(station['_id'], {
                    "name": nameController.text,
                    "city": cityController.text,
                    "address": addressController.text,
                    "price": priceController.text,
                    "totalSlots": int.parse(totalSlotsController.text),
                    "availableSlots": int.parse(availableSlotsController.text),
                  });

                  Navigator.pop(context);
                  fetchStations(); // refresh UI
                } catch (e) {
                  debugPrint("Update error: $e");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBookingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Bookings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: ['All', 'Active', 'Completed'].map((filter) {
                    final isSelected = selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => selectedFilter = filter),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF67C090)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // Booking list
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
                    child: Text(
                      'No bookings found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(filteredBookings[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map booking) {
    final user = booking['user'] ?? {};
    final status = (booking['status'] ?? 'unknown').toString().toLowerCase();

    final statusColors = {
      'active': {
        'border': const Color(0xFF67C090),
        'bg': const Color(0xFFEAF7F1),
        'text': const Color(0xFF2E9E68),
      },
      'confirmed': {
        'border': const Color(0xFF67C090),
        'bg': const Color(0xFFEAF7F1),
        'text': const Color(0xFF2E9E68),
      },
      'completed': {
        'border': const Color(0xFF4299E1),
        'bg': const Color(0xFFEBF4FD),
        'text': const Color(0xFF185FA5),
      },
    };

    final colors =
        statusColors[status] ??
        {
          'border': Colors.grey,
          'bg': Colors.grey[100]!,
          'text': Colors.grey[700]!,
        };

    final dateTime = booking['date'] != null
        ? DateTime.tryParse(booking['date'])
        : null;
    final formattedDate = dateTime != null
        ? DateFormat('MMM dd').format(dateTime)
        : (booking['date'] ?? '-');
    final duration = booking['duration'] ?? 0;
    final price = booking['price'] ?? '0';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors['border'] as Color, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name + Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Rs. $price',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC06797),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Status badge + duration/date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors['bg'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors['text'],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$duration hr  •  $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),

            // Row 3: User contact + Vehicle info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMiniInfo(Icons.email, user['email'] ?? '-'),
                      const SizedBox(height: 4),
                      _buildMiniInfo(Icons.phone, user['phone'] ?? '-'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMiniInfo(
                        Icons.directions_car,
                        booking['vehicleNumber'] ?? '-',
                      ),
                      const SizedBox(height: 4),
                      _buildMiniInfo(
                        Icons.bolt,
                        '${booking['plugType'] ?? '-'} ${booking['plugPower'] ?? ''}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
