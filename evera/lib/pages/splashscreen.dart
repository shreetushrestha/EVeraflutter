import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../services/auth_service.dart';
import '../services/session.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    Session.loadFromHive();

    if (Session.token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final res = await AuthService().getUserById(Session.userId!);

      if (res != null && res.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await Session.clear();
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      await Session.clear();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
