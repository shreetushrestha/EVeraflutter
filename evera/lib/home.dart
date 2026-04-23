import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../models/evmodel.dart';
import 'dart:convert';
import 'dart:async';

import 'package:evera/pages/bookings.dart';
import 'package:evera/pages/search.dart';
import 'package:evera/pages/profile.dart';
import 'package:evera/pages/bookingpage.dart';
import '../widgets/bottom_nav.dart';

import '../services/station_service.dart';
import '../services/session.dart';

/// ================= HOME PAGE =================
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MapController _mapController = MapController();

  List<EvModel> items = [];
  LatLng? userLocation;
  bool isLoading = true;

  bool followUser = true;

  List<LatLng> routePoints = [];
  bool showRoute = false;
  bool showStationList = true;

  double nearbyRadiusKm = 10;
  Set<String> favoriteIds = {};

  EvModel? selectedStation;

  StreamSubscription<Position>? _positionStream;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    fetchStations();
    startLocationTracking(); // 👈 instead of getUserLocation()
    loadFavorites();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await StationService().getFavorites();
      if (mounted) {
        setState(() {
          favoriteIds = favorites?.whereType<String>().toSet() ?? {};
        });
      }
    } catch (e) {
      debugPrint("Failed to load favorites: $e");
      // Continue without favorites if loading fails
      if (mounted) {
        setState(() {
          favoriteIds = {};
        });
      }
    }
  }

  Future<void> fetchStations() async {
    try {
      final rawStations = await StationService().getAllStations();

      setState(() {
        items = rawStations.map<EvModel>((e) {
          return EvModel.fromJson(e);
        }).toList();

        isLoading = false;
      });
    } catch (e, s) {
      debugPrint("Station fetch error: $e");
      debugPrintStack(stackTrace: s);
      setState(() => isLoading = false);
    }
  }

  /// ================= USER LOCATION =================
  Future<void> startLocationTracking() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          final newLocation = LatLng(position.latitude, position.longitude);

          setState(() {
            userLocation = newLocation;
          });

          if (followUser) {
            _mapController.move(newLocation, _mapController.camera.zoom);
          }
        });
  }

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
        showStationList = false;
      });

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(routePoints),
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  String getPlugText(List<Plug> plugs) {
    if (plugs.isEmpty) return "N/A";

    return plugs.map((p) => "${p.plug} - ${p.power} - ${p.type}").join(", ");
  }

  List<EvModel> get filteredStations {
    if (selectedFilter == "All") {
      return items;
    }

    if (selectedFilter == "Nearby" && userLocation != null) {
      final nearbyStations = items.where((station) {
        final distanceInMeters = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          station.latitude,
          station.longitude,
        );
        final distanceInKm = distanceInMeters / 1000;
        return distanceInKm <= nearbyRadiusKm;
      }).toList();

      // Sort ascending by distance (nearest first)
      nearbyStations.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyStations;
    }

    if (selectedFilter == "Favorites") {
      return items
          .where((station) => favoriteIds.contains(station.id))
          .toList();
    }

    return items;
  }

  void openStationOverlay(EvModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          controller: _sheetController,
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
                child: stationDetailContent(item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ================= MAP =================
          GestureDetector(
            onTap: () {
              setState(() {
                selectedStation = null;
              });

              _sheetController.animateTo(
                0.25,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(28.20833, 83.95804),
                initialZoom: 13,
              ),
              children: [
                openStreetMapTileLayer,

                /// USER MARKER
                if (userLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 24,
                        height: 24,
                        point: userLocation!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),

                /// STATION MARKERS
                MarkerLayer(
                  markers: items.map((item) {
                    return Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(item.latitude, item.longitude),
                      child: GestureDetector(
                        onTap: () {
                          if (selectedStation?.id == item.id) {
                            openStationOverlay(item);
                          } else {
                            setState(() {
                              selectedStation = item;
                            });
                          }
                        },
                        child: chargerMarker(item),
                      ),
                    );
                  }).toList(),
                ),

                /// POPUP
                if (selectedStation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 200,
                        height: 120,
                        point: LatLng(
                          selectedStation!.latitude,
                          selectedStation!.longitude,
                        ),
                        alignment: Alignment.topCenter,
                        child: stationPopup(selectedStation!),
                      ),
                    ],
                  ),

                /// ROUTE
                if (showRoute)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),

          /// ================= TOP BUTTONS =================
          Positioned(
            top: 350,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.zoom_out_map, color: Colors.black),
              onPressed: () {
                _mapController.move(_mapController.camera.center, 10);

                setState(() {
                  showStationList = false;
                });
              },
            ),
          ),

          Positioned(
            top: 400,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              child: const Icon(Icons.list, color: Colors.black),
              onPressed: () {
                setState(() {
                  showStationList = true;
                });
              },
            ),
          ),

          /// ================= STATION LIST =================
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.4,
            minChildSize: 0.25,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.4, 0.95],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// DRAG HANDLE
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// FILTERS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          filterChip("All"),
                          const SizedBox(width: 8),
                          filterChip("Nearby"),
                          const SizedBox(width: 8),
                          filterChip("Favorites"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// LIST
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: filteredStations.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) =>
                            stationCard(filteredStations[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          /// ================= MAP BUTTON (ALWAYS ON TOP) =================
          Positioned(
            top: 450,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.map, color: Colors.black),
              onPressed: () {
                _sheetController.animateTo(
                  0.25,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),

      /// ================= NAV BAR =================
      bottomNavigationBar: bottomNav(context, 0),
    );
  }

  /// ================= MARKER ICON =================
  Widget chargerMarker(EvModel item) {
    final isSelected = selectedStation?.id == item.id;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.green,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: const Icon(Icons.ev_station, color: Colors.white),
    );
  }

  String selectedFilter = "All";
  Widget stationsContainer() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// FILTER ROW
          Row(
            children: [
              filterChip("All"),
              const SizedBox(width: 8),
              filterChip("Nearby"),
              const SizedBox(width: 8),
              filterChip("Favorites"),
            ],
          ),

          /// STATION LIST
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: filteredStations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => stationCard(filteredStations[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget stationPopup(EvModel item) {
    final isAvailable = item.availableSlots > 0 && item.isOperational;

    double? distanceKm;
    if (userLocation != null) {
      final meters = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        item.latitude,
        item.longitude,
      );
      distanceKm = meters / 1000;
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // 👈 IMPORTANT
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          constraints: const BoxConstraints(
            maxWidth: 180,
          ), // 👈 prevents overflow
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isAvailable ? "Available" : "Unavailable",
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontSize: 11,
                ),
              ),

              if (distanceKm != null)
                Text(
                  "${distanceKm.toStringAsFixed(1)} km",
                  style: const TextStyle(fontSize: 11),
                ),

              Text(
                item.price,
                style: const TextStyle(fontSize: 11, color: Colors.orange),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        /// SMALL POINTER
        const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
      ],
    );
  }

  Widget filterChip(String text) {
    final isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple[300] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isActive ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget stationCard(EvModel item) {
    final plug = getPlugText(item.plugs);
    final isFavorite = favoriteIds.contains(item.id);

    double? distanceKm;
    if (userLocation != null) {
      final meters = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        item.latitude,
        item.longitude,
      );
      distanceKm = meters / 1000;
    }

    return GestureDetector(
      onTap: () => openStationOverlay(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => toggleFavorite(item.id),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    statusBadge(item),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            if (distanceKm != null)
              Text(
                "${distanceKm.toStringAsFixed(1)} km away",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 6),
            Text("⚡ $plug"),
            const SizedBox(height: 10),
            Text(
              "Price: ${item.price}",
              style: const TextStyle(fontSize: 16, color: Colors.orange),
            ),

            Text(
              "${item.availableSlots}/${item.totalSlots} slots available",
              style: TextStyle(
                color: item.availableSlots > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                amenitiesRow(item),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBadge(EvModel item) {
    final isAvailable = item.availableSlots > 0 && item.isOperational;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? "Available" : "Unavailable",
        style: TextStyle(
          color: isAvailable ? Colors.green : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ================= AMENITIES =================
  Widget amenitiesRow(EvModel item) {
    return Row(
      children: [
        if (item.amenities.any((a) => a.toLowerCase().contains('food')))
          const Icon(Icons.restaurant, size: 18),
        if (item.amenities.any((a) => a.toLowerCase().contains('wifi')))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.wifi, size: 18),
          ),
        if (item.amenities.any((a) => a.toLowerCase().contains('parking')))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.local_parking, size: 18),
          ),
      ],
    );
  }

  /// ================= NAV BAR =================
  Widget bottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  stations: items,
                  favoriteIds: favoriteIds,
                  userLocation: userLocation,
                ),
              ),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BookingsPage()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Bookings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  Widget stationDetailContent(EvModel item) {
    final imageUrl = item.images.isNotEmpty ? item.images.first : null;
    final priceStr = item.price; // "Rs. 15/kWh"
    final isAvailable = item.availableSlots > 0 && item.isOperational;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
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

          // NAME + PRICE
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priceStr,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address + city
          Text(item.address, style: const TextStyle(fontSize: 14)),
          Text(
            "${item.city}, ${item.province.isEmpty ? 'N/A' : item.province}",
            style: const TextStyle(fontSize: 14),
          ),
          if (item.telephone.isNotEmpty)
            Text(
              "Tel: ${item.telephone}",
              style: const TextStyle(fontSize: 14),
            ),

          const SizedBox(height: 12),

          // Plugs
          const Text(
            "Charging Plugs",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          item.plugs.isEmpty
              ? const Text("No plugs available")
              : Wrap(
                  spacing: 10,
                  children: item.plugs.map((p) {
                    return Chip(
                      label: Text("${p.plug} • ${p.power} • ${p.type}"),
                      backgroundColor: Colors.green[100],
                    );
                  }).toList(),
                ),

          const SizedBox(height: 12),

          // Station type
          const Text(
            "Station Type",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: item.type
                .map(
                  (t) =>
                      Chip(label: Text(t), backgroundColor: Colors.blue[100]),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          // Amenities
          const Text(
            "Amenities",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

          // Book Now
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
                      ).then((result) {
                        if (result == true) {
                          fetchStations();

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.3),
                            builder: (_) {
                              return Dialog(
                                elevation: 10, // 👈 adds depth
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFE8F5E9),
                                        size: 50,
                                      ),
                                      const SizedBox(height: 12),

                                      const Text(
                                        "Booking Successful 🎉",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        "Your charging slot has been booked successfully.",
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 20),

                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFE8F5E9),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      });
                    }
                  : null,
              child: const Text("Book Now"),
            ),
          ),

          const SizedBox(height: 12),

          // Directions
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text("Directions"),
              onPressed: () {
                Navigator.pop(context); // close bottom sheet

                getRoute(LatLng(item.latitude, item.longitude));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggleFavorite(String stationId) async {
    if (stationId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid station ID")));
      return;
    }

    try {
      final isFavorite = favoriteIds.contains(stationId);

      if (isFavorite) {
        await StationService().removeFavorite(stationId);
        if (mounted) {
          setState(() {
            favoriteIds.remove(stationId);
          });
        }
      } else {
        await StationService().addFavorite(stationId);
        if (mounted) {
          setState(() {
            favoriteIds.add(stationId);
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to toggle favorite for $stationId: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().substring(0, 50)}")),
        );
      }
    }
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// ================= TILE LAYER =================
TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.evera.app',
);
