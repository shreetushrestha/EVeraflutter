import 'package:flutter/material.dart';
import '../services/station_service.dart';
import 'sidebar.dart';
import 'admin.dart';

class ManageStationsPage extends StatefulWidget {
  const ManageStationsPage({super.key});

  @override
  State<ManageStationsPage> createState() => _ManageStationsPageState();
}

class _ManageStationsPageState extends State<ManageStationsPage> {
  final StationService _stationService = StationService();

  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          /// 🔥 SIDEBAR
          AdminSidebar(
            selectedIndex: 1,
            onHomeTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
              );
            },
          ),

          /// 🔥 MAIN CONTENT
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 HEADER
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text(
                              "Search Stations",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF67C090),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _openCreateStation,
                              icon: const Icon(Icons.add),
                              label: const Text("Create Station"),
                            ),
                          ],
                        ),
                      ),

                      /// 🔍 SEARCH
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search stations...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 📦 GRID
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredStations.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: 1.55,
                              ),
                          itemBuilder: (context, index) {
                            final station = _filteredStations[index];

                            final images = _toList(station['images']);
                            final types = _toList(station['type']);
                            final amenities = _toList(station['amenities']);

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// 🖼 IMAGE + BADGES
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: 170,
                                        width: double.infinity,
                                        child: images.isNotEmpty
                                            ? Image.network(
                                                images[0],
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                              ),
                                      ),

                                      /// ✅ Availability badge
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (station['availableSlots'] ??
                                                        0) >
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            "${station['availableSlots'] ?? 0}/${station['totalSlots'] ?? 0} Available",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// ✏ EDIT
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _openEditStation(station),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.pink,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  /// 📄 DETAILS
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        /// TITLE
                                        Text(
                                          station['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        /// LOCATION
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${station['city']}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Text(
                                          station['address'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        /// ⚡ TYPES (chips)
                                        Wrap(
                                          spacing: 6,
                                          children: types.map((t) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.pink.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                t,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),

                                        const SizedBox(height: 8),

                                        /// 💰 PRICE
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.attach_money,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              " ${station['price'] ?? 'Rs. 15/kWh'}",
                                            ),
                                          ],
                                        ),

                                        /// 📞 PHONE
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              " ${station['telephone'] ?? ''}",
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        /// 🧰 AMENITIES
                                        Text(
                                          amenities.join(" • "),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        /// 📍 LAT LONG
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Lat: ${station['latitude']}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              "Long: ${station['longitude']}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchStations() async {
    try {
      final data = await _stationService.getAllStations();
      if (!mounted) return;
      setState(() {
        stations = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnack('Failed to load stations');
    }
  }

  List<Map<String, dynamic>> get _filteredStations {
    if (searchQuery.trim().isEmpty) return stations;
    final q = searchQuery.toLowerCase();

    return stations.where((station) {
      final blob = [
        station['name'],
        station['city'],
        station['province'],
        station['address'],
        station['telephone'],
        _managerLabel(station['manager']),
        station['price'],
      ].map((e) => e?.toString().toLowerCase() ?? '').join(' | ');

      return blob.contains(q);
    }).toList();
  }

  Future<void> _openCreateStation() async {
    await _openStationForm();
  }

  Future<void> _openEditStation(Map<String, dynamic> station) async {
    await _openStationForm(station: station);
  }

  Future<void> _openStationForm({Map<String, dynamic>? station}) async {
    const themePurple = Color(0xFF7B4DFF);

    final nameController = TextEditingController(
      text: station?['name']?.toString() ?? '',
    );
    final cityController = TextEditingController(
      text: station?['city']?.toString() ?? '',
    );
    final provinceController = TextEditingController(
      text: station?['province']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: station?['address']?.toString() ?? '',
    );
    final telephoneController = TextEditingController(
      text: station?['telephone']?.toString() ?? '',
    );
    final latitudeController = TextEditingController(
      text: station?['latitude']?.toString() ?? '',
    );
    final longitudeController = TextEditingController(
      text: station?['longitude']?.toString() ?? '',
    );
    final totalSlotsController = TextEditingController(
      text: station?['totalSlots']?.toString() ?? '1',
    );
    final availableSlotsController = TextEditingController(
      text: station?['availableSlots']?.toString() ?? '1',
    );
    final priceController = TextEditingController(
      text: station?['price']?.toString() ?? 'Rs. 15/kWh',
    );
    final managerController = TextEditingController(
      text: _managerId(station?['manager']),
    );
    final typeController = TextEditingController(
      text: _joinList(station?['type']),
    );
    final amenitiesController = TextEditingController(
      text: _joinList(station?['amenities']),
    );
    final imagesController = TextEditingController(
      text: _joinList(station?['images']),
    );
    final plugsController = TextEditingController(
      text: _plugsToText(station?['plugs']),
    );
    bool isOperational = station?['isOperational'] == true;

    final isEditing = station != null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isEditing ? 'Edit Station' : 'Create Station',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _formGrid([
                        _textField(nameController, 'Station name'),
                        _textField(cityController, 'City'),
                        _textField(provinceController, 'Province'),
                        _textField(addressController, 'Address'),
                        _textField(telephoneController, 'Telephone'),
                        _textField(
                          latitudeController,
                          'Latitude',
                          keyboard: TextInputType.number,
                        ),
                        _textField(
                          longitudeController,
                          'Longitude',
                          keyboard: TextInputType.number,
                        ),
                        _textField(
                          totalSlotsController,
                          'Total slots',
                          keyboard: TextInputType.number,
                        ),
                        _textField(
                          availableSlotsController,
                          'Available slots',
                          keyboard: TextInputType.number,
                        ),
                        _textField(priceController, 'Price'),
                        _textField(managerController, 'Manager ID'),
                        _textField(typeController, 'Type (comma separated)'),
                        _textField(
                          amenitiesController,
                          'Amenities (comma separated)',
                        ),
                        _textField(
                          imagesController,
                          'Images URLs (comma separated)',
                        ),
                        _textField(
                          plugsController,
                          'Plugs (one per line: plug|power|type)',
                          maxLines: 4,
                        ),
                      ]),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isOperational,
                        onChanged: (v) {
                          setLocalState(() => isOperational = v);
                        },
                        title: const Text('Operational'),
                      ),
                      const SizedBox(height: 18),
                      if (isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      title: const Text('Delete station'),
                                      content: Text(
                                        'Delete "${nameController.text}" permanently?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed != true) return;

                                  try {
                                    await _stationService.deleteStation(
                                      station!['_id'].toString(),
                                    );
                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);
                                    _showSnack('Station deleted');
                                    _fetchStations();
                                  } catch (e) {
                                    _showSnack(e.toString());
                                  }
                                },
                                child: const Text('Delete'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themePurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    final payload = _buildPayload(
                                      nameController: nameController,
                                      cityController: cityController,
                                      provinceController: provinceController,
                                      addressController: addressController,
                                      telephoneController: telephoneController,
                                      latitudeController: latitudeController,
                                      longitudeController: longitudeController,
                                      totalSlotsController:
                                          totalSlotsController,
                                      availableSlotsController:
                                          availableSlotsController,
                                      priceController: priceController,
                                      managerController: managerController,
                                      typeController: typeController,
                                      amenitiesController: amenitiesController,
                                      imagesController: imagesController,
                                      plugsController: plugsController,
                                      isOperational: isOperational,
                                    );

                                    await _stationService.updateStation(
                                      station!['_id'].toString(),
                                      payload,
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);
                                    _showSnack('Station updated');
                                    _fetchStations();
                                  } catch (e) {
                                    _showSnack(e.toString());
                                  }
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themePurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    final payload = _buildPayload(
                                      nameController: nameController,
                                      cityController: cityController,
                                      provinceController: provinceController,
                                      addressController: addressController,
                                      telephoneController: telephoneController,
                                      latitudeController: latitudeController,
                                      longitudeController: longitudeController,
                                      totalSlotsController:
                                          totalSlotsController,
                                      availableSlotsController:
                                          availableSlotsController,
                                      priceController: priceController,
                                      managerController: managerController,
                                      typeController: typeController,
                                      amenitiesController: amenitiesController,
                                      imagesController: imagesController,
                                      plugsController: plugsController,
                                      isOperational: isOperational,
                                    );

                                    await _stationService.createStation(
                                      payload,
                                    );

                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);
                                    _showSnack('Station created');
                                    _fetchStations();
                                  } catch (e) {
                                    _showSnack(e.toString());
                                  }
                                },
                                child: const Text('Create Station'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _buildPayload({
    required TextEditingController nameController,
    required TextEditingController cityController,
    required TextEditingController provinceController,
    required TextEditingController addressController,
    required TextEditingController telephoneController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required TextEditingController totalSlotsController,
    required TextEditingController availableSlotsController,
    required TextEditingController priceController,
    required TextEditingController managerController,
    required TextEditingController typeController,
    required TextEditingController amenitiesController,
    required TextEditingController imagesController,
    required TextEditingController plugsController,
    required bool isOperational,
  }) {
    final totalSlots = int.tryParse(totalSlotsController.text.trim());
    final availableSlots = int.tryParse(availableSlotsController.text.trim());
    final latitude = double.tryParse(latitudeController.text.trim());
    final longitude = double.tryParse(longitudeController.text.trim());

    if (nameController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        latitude == null ||
        longitude == null ||
        totalSlots == null ||
        availableSlots == null ||
        managerController.text.trim().isEmpty) {
      throw Exception('Please fill in all required fields correctly');
    }

    if (availableSlots > totalSlots) {
      throw Exception('Available slots cannot exceed total slots');
    }

    return {
      'name': nameController.text.trim(),
      'city': cityController.text.trim(),
      'province': provinceController.text.trim(),
      'address': addressController.text.trim(),
      'telephone': telephoneController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'price': priceController.text.trim().isEmpty
          ? 'Rs. 15/kWh'
          : priceController.text.trim(),
      'manager': managerController.text.trim(),
      'isOperational': isOperational,
      'type': _splitCsv(typeController.text),
      'amenities': _splitCsv(amenitiesController.text),
      'images': _splitCsv(imagesController.text),
      'plugs': _parsePlugs(plugsController.text),
    };
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> _parsePlugs(String value) {
    final lines = value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return lines.map((line) {
      final parts = line.split('|').map((e) => e.trim()).toList();
      return {
        'plug': parts.isNotEmpty ? parts[0] : '',
        'power': parts.length > 1 ? parts[1] : '',
        'type': parts.length > 2 ? parts[2] : '',
      };
    }).toList();
  }

  String _joinList(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  String _plugsToText(dynamic value) {
    if (value == null || value is! List || value.isEmpty) return '';
    return value
        .map((item) {
          if (item is Map) {
            final plug = item['plug']?.toString() ?? '';
            final power = item['power']?.toString() ?? '';
            final type = item['type']?.toString() ?? '';
            return '$plug|$power|$type';
          }
          return item.toString();
        })
        .join('\n');
  }

  String _managerId(dynamic manager) {
    if (manager is Map) {
      return manager['_id']?.toString() ?? manager['id']?.toString() ?? '';
    }
    return manager?.toString() ?? '';
  }

  String _managerLabel(dynamic manager) {
    if (manager is Map) {
      return manager['name']?.toString() ??
          manager['fullName']?.toString() ??
          manager['email']?.toString() ??
          manager['_id']?.toString() ??
          'Assigned manager';
    }
    return manager?.toString() ?? 'Assigned manager';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _formGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 4.6 : 3.8,
          children: children,
        );
      },
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  List<String> _toList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [value.toString()];
  }

  Widget _line(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "$label: ${value ?? '-'}",
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
