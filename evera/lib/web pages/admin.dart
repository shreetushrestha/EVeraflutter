import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'manage_stations.dart';

import '../services/session.dart';
import '../services/station_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    const themePurple = Color(0xFF7B4DFF);

    final pages = <Widget>[
      AdminOverviewTab(
        profileKey: _profileKey,
        onOpenProfileMenu: _showProfileMenu,
      ),
      const ManageStationsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Row(
          children: [
            // ✅ LEFT SIDE NAV BAR
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              indicatorColor: themePurple.withOpacity(0.16),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: Text('Manage Stations'),
                ),
              ],
            ),

            // ✅ MAIN CONTENT
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  Future<void> _showProfileMenu() async {
    final themePurple = const Color(0xFF7B4DFF);

    final RenderBox box =
        _profileKey.currentContext!.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(_profileKey.currentContext!).context.findRenderObject()
            as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFEDE7FF),
                      child: Icon(Icons.person, color: Color(0xFFC06797)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Admin Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Session.token == null || Session.token!.isEmpty
                      ? 'No active session'
                      : 'Signed in as administrator',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  'You can manage stations, edit details, and log out from here.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result == 'logout') {
      Session.token = null;
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }
}

class AdminOverviewTab extends StatefulWidget {
  final GlobalKey profileKey;
  final VoidCallback onOpenProfileMenu;

  const AdminOverviewTab({
    super.key,
    required this.profileKey,
    required this.onOpenProfileMenu,
  });

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  final StationService _stationService = StationService();

  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;
  String? errorMessage;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      final data = await _stationService.getAllStations();
      if (!mounted) return;
      setState(() {
        stations = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  int get _totalChargers {
    int total = 0;
    for (final station in stations) {
      total += _toList(station['plugs']).length;
    }
    return total;
  }

  int get _operationalStations {
    return stations.where((s) => s['isOperational'] == true).length;
  }

  void _showStationInfo(Map<String, dynamic> station) {
    final manager = _managerLabel(station['manager']);
    final plugs = _toList(station['plugs']);
    final types = _toList(station['type']);
    final amenities = _toList(station['amenities']);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(station['name']?.toString() ?? 'Station'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoLine('Manager', manager),
                  _infoLine('City', station['city']?.toString() ?? '-'),
                  _infoLine('Province', station['province']?.toString() ?? '-'),
                  _infoLine('Address', station['address']?.toString() ?? '-'),
                  _infoLine(
                    'Telephone',
                    station['telephone']?.toString() ?? '-',
                  ),
                  _infoLine(
                    'Location',
                    '${station['latitude'] ?? '-'}, ${station['longitude'] ?? '-'}',
                  ),
                  _infoLine(
                    'Slots',
                    '${station['availableSlots'] ?? 0}/${station['totalSlots'] ?? 0}',
                  ),
                  _infoLine(
                    'Operational',
                    station['isOperational'] == true ? 'Yes' : 'No',
                  ),
                  _infoLine('Price', station['price']?.toString() ?? '-'),
                  _infoLine('Types', types.isEmpty ? '-' : types.join(', ')),
                  _infoLine(
                    'Amenities',
                    amenities.isEmpty ? '-' : amenities.join(', '),
                  ),
                  _infoLine(
                    'Plugs',
                    plugs.isEmpty ? '-' : '${plugs.length} plug(s)',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const themePurple = Color(0xFF7B4DFF);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              GestureDetector(
                key: widget.profileKey,
                onTap: widget.onOpenProfileMenu,
                child: const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFFEDE7FF),
                  child: Icon(Icons.person, color: themePurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchStations,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatCard(
                            title: 'Charging Stations',
                            value: stations.length.toString(),
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Total Chargers',
                            value: _totalChargers.toString(),
                          ),
                          const SizedBox(width: 16),
                          _StatCard(
                            title: 'Operational',
                            value: _operationalStations.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 980;
                          final mapHeight = isNarrow ? 320.0 : 520.0;

                          return SizedBox(
                            height: mapHeight,
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: _mapView()),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: _recentStationsPanel(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapView() {
    final defaultCenter = stations.isNotEmpty
        ? LatLng(
            _toDouble(stations.first['latitude'], 28.20833),
            _toDouble(stations.first['longitude'], 83.95804),
          )
        : const LatLng(28.20833, 83.95804);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: defaultCenter, initialZoom: 12.5),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.evera.app',
          ),
          MarkerLayer(
            markers: stations.map((station) {
              return Marker(
                width: 44,
                height: 44,
                point: LatLng(
                  _toDouble(station['latitude'], 0),
                  _toDouble(station['longitude'], 0),
                ),
                child: GestureDetector(
                  onTap: () => _showStationInfo(station),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.ev_station, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _recentStationsPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Station Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: math.min(stations.length, 6),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final station = stations[index];
                return InkWell(
                  onTap: () => _showStationInfo(station),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station['name']?.toString() ?? 'Station',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${station['city'] ?? '-'}, ${station['province'] ?? '-'}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Manager: ${_managerLabel(station['manager'])}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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

  double _toDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
