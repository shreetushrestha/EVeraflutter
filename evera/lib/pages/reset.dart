import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/station_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passCtrl = TextEditingController();

  Future<void> reset() async {
    await Dio().post(
      '${StationService.baseUrl}api/v1/auth/reset-password/${widget.token}',
      data: {'password': passCtrl.text},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: reset, child: const Text("Reset")),
          ],
        ),
      ),
    );
  }
}
