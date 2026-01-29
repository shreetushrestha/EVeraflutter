import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:evera/create.dart';
import 'package:evera/web%20pages/admin.dart';
import 'package:evera/pages/bookings.dart';
import 'package:evera/pages/stations_page.dart';
import 'package:evera/test.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'home.dart';
import 'web pages/admin.dart';
import 'pages/stations_page.dart';
import 'web pages/CSM.dart';
import 'web pages/login.web.dart';
import 'web pages/admin.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👇 PLATFORM-BASED ENTRY POINT
      home: kIsWeb
          ? const WebManagerLogin()   // or ManagerPage()
          : const LandingPage(),

      routes: {
        '/admin': (context) => const AdminHomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const Home(),
        '/form': (context) => const BookingsPage(),
        '/allstation': (context) => StationsPage(),
        '/mystation': (context) => const ManagerPage(),
      },
    );
  }
}
