import 'package:evera/create.dart';
import 'package:evera/test.dart';
import 'package:flutter/material.dart';
import 'models/login.dart';
import 'models/signup.dart';
import 'home.dart';

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
    '/login': (context) => const LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/home': (context) => const Home(),
  },
);
  }
  }