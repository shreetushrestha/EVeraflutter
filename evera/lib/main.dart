import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:evera/landingpage.dart';
import 'package:flutter/material.dart';
import 'home.dart';

import 'web pages/CSM.dart';
import 'web pages/loginweb.dart';
import 'web pages/signupweb.dart';
import 'pages/auth_page.dart'; 

import 'services/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('myBox');

  // 🔑 Restore login state
  Session.loadFromHive();

  runApp(
    const MyApp(),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: kIsWeb
          ? const WebManagerLogin()
          : Session.isLoggedIn
              ? const Home()
              : const LandingPage(),

      routes: {
        '/login': (_) => const AuthPage(),
        '/home': (_) => const Home(),
        '/mystation': (_) => const ManagerPage(),
      },
    );
  }
}


