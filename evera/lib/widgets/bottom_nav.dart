import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../pages/bookings.dart';
import '../pages/profile.dart';
import '../pages/search.dart';
import '../home.dart';
import '../models/evmodel.dart';

/// Bottom navigation bar helper.  The extra arguments are used when
/// navigating to the search page so that it can reuse already-fetched
/// station data instead of hitting the network again.
///
/// All parameters are optional and default to empty, allowing existing
/// callers to remain unchanged.
Widget bottomNav(
  BuildContext context,
  int index, {
  List<EvModel> stations = const [],
  Set<String> favoriteIds = const {},
  LatLng? userLocation,
}) {
  return BottomNavigationBar(
    currentIndex: index,
    type: BottomNavigationBarType.fixed,
    onTap: (i) {
      if (i == index) return;

      switch (i) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SearchPage(
                stations: stations,
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
      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Bookings"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ],
  );
}
