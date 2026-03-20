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

  /// SEARCH FUNCTION
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

  /// OPEN STATION DETAILS
  void openStationOverlay(EvModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),

              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: [
                  /// DRAG HANDLE
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  stationDetailContent(item),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// STATION CARD
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

  /// STATION DETAIL CONTENT
  Widget stationDetailContent(EvModel item) {
    final imageUrl = item.images.isNotEmpty ? item.images.first : null;

    final priceStr = item.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// IMAGE
        if (imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),

            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40),
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        /// NAME + PRICE
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

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

        /// ADDRESS
        Text(item.address),

        Text("${item.city}, ${item.province.isEmpty ? 'N/A' : item.province}"),

        if (item.telephone.isNotEmpty) Text("Tel: ${item.telephone}"),

        const SizedBox(height: 20),

        /// CHARGING PLUGS
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

        /// AMENITIES
        const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold)),

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

        /// BOOK NOW
        SizedBox(
          width: double.infinity,
          height: 50,

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

        const SizedBox(height: 12),

        /// DIRECTIONS
        SizedBox(
          width: double.infinity,
          height: 50,

          child: OutlinedButton.icon(
            icon: const Icon(Icons.directions),

            label: const Text("Directions"),

            onPressed: () {
              Navigator.pop(context);

              getRoute(LatLng(item.latitude, item.longitude));
            },
          ),
        ),
      ],
    );
  }

  /// BUILD
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

              /// SEARCH FIELD
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

              /// RESULTS
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

  /// ROUTE FUNCTION PLACEHOLDER
  void getRoute(LatLng destination) {}
}
