import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/evmodel.dart';
import '../pages/bookingpage.dart';
import '../widgets/bottom_nav.dart';

class SearchPage extends StatefulWidget {
  final List<EvModel> stations;
  final Set<String> favoriteIds;
  final LatLng? userLocation;

  const SearchPage({
    super.key,
    required this.stations,
    required this.favoriteIds,
    required this.userLocation,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<EvModel> filtered = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.stations;
  }

  void performSearch(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filtered = widget.stations;
      } else {
        final lowerKeyword = keyword.toLowerCase();
        filtered = widget.stations.where((station) {
          return station.name.toLowerCase().contains(lowerKeyword) ||
              station.address.toLowerCase().contains(lowerKeyword) ||
              station.city.toLowerCase().contains(lowerKeyword);
        }).toList();
      }
    });
  }

  void openStationOverlay(EvModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: stationDetailContent(item),
        );
      },
    );
  }

  Widget stationCard(EvModel item) {
    final isFavorite = widget.favoriteIds.contains(item.id);

    double? distanceKm;
    if (widget.userLocation != null) {
      final meters = Geolocator.distanceBetween(
        widget.userLocation!.latitude,
        widget.userLocation!.longitude,
        item.latitude,
        item.longitude,
      );
      distanceKm = meters / 1000;
    }

    return GestureDetector(
      onTap: () => openStationOverlay(item),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (distanceKm != null)
              Text(
                "${distanceKm.toStringAsFixed(1)} km away",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 6),
            Text("Price: ${item.price}"),
          ],
        ),
      ),
    );
  }

  Widget stationDetailContent(EvModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(item.address),
        const SizedBox(height: 10),
        Text("Price: ${item.price}"),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: item.isOperational
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(station: item),
                      ),
                    );
                  }
                : null,
            child: const Text("Book Now"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                onChanged: performSearch,
                decoration: InputDecoration(
                  hintText: "Search charging stations",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          "No stations found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, index) => stationCard(filtered[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNav(
        context,
        1,
        stations: widget.stations,
        favoriteIds: widget.favoriteIds,
        userLocation: widget.userLocation,
      ),
    );
  }
}
