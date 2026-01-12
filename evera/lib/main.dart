import 'package:evera/create.dart';
import 'package:evera/pages/admin.dart';
import 'package:evera/pages/bookings.dart';
import 'package:evera/pages/stations_page.dart';
import 'package:evera/test.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'home.dart';
import 'pages/admin.dart';
import 'pages/stations_page.dart';
import 'pages/CSM.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build (BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/': (context) => const LandingPage(),
    '/manager': (context) => StationsPage(),
    '/mystation': (context) => const ManagerPage(),
    // '/': (context) => const AdminHomePage(),
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/home': (context) => const Home(),
    '/form': (context) => const BookingsPage(),
  },
);
  }
  }