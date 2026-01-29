import 'package:flutter/material.dart';
import '../pages/bookings.dart';
import '../pages/profile.dart';
import '../pages/search.dart';
import '../home.dart';

Widget bottomNav(BuildContext context, int index) {
  return BottomNavigationBar(
    currentIndex: index,
    type: BottomNavigationBarType.fixed,
    onTap: (i) {
      if (i == index) return;

      switch (i) {
        case 0:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
          break;
        case 1:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchPage()));
          break;
        case 2:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsPage()));
          break;
        case 3:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
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
