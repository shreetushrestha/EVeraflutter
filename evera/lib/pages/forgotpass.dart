import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/station_service.dart';
import 'reset.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  bool loading = false;
  bool canResend = false;

  Future<void> sendReset({bool isResend = false}) async {
    setState(() => loading = true);

    try {
      final res = await Dio().post(
        '${StationService.baseUrl}api/v1/auth/forgot-password',
        data: {'email': emailCtrl.text.trim()},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.data['message'])),
      );

      if (!isResend) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: emailCtrl.text.trim()),
          ),
        );
      }

      setState(() => canResend = false);
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted) setState(() => canResend = true);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send reset code")),
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

          /// TITLE
          const Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "We’ll send a verification code to your email",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 60),

          /// CARD
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    decoration: inputStyle("Enter your email"),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : () => sendReset(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC06797),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        loading ? "Sending..." : "Send Code",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed:
                          canResend ? () => sendReset(isResend: true) : null,
                      child: Text(
                        "Resend code",
                        style: TextStyle(
                          color: canResend
                              ? const Color(0xFFC06797)
                              : Colors.grey,
                        ),
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
