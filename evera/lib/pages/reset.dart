import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/station_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final otpCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;

  Future<void> resetPassword() async {
    if (passCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await Dio().post(
        '${StationService.baseUrl}api/v1/auth/reset-password',
        data: {
          "email": widget.email.trim(),
          "token": otpCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? "Invalid code"),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F6F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67C090),
      body: Column(
        children: [
          const SizedBox(height: 140),

          const Text(
            "Reset Password",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),
          Text(
            "Enter the code sent to ${widget.email}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 60),

          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: inputStyle("4-digit code"),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: inputStyle("New password"),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: inputStyle("Confirm password"),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC06797),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        loading ? "Updating..." : "Reset Password",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
