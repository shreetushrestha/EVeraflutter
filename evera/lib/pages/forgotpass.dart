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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res.data['message'])));

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget labeledInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onInfoTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onInfoTap,
              child: const Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(controller: controller, decoration: inputStyle(hint)),
      ],
    );
  }

  void showInfo(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67C090),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// BACK BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 40),

            /// TITLE
            const Text(
              "Forgot Password",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              "We’ll send a verification code to your email",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 40),

            /// WHITE CARD
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                margin: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labeledInput(
                      label: "Email",
                      controller: emailCtrl,
                      hint: "Enter your email",
                      onInfoTap: () => showInfo(
                        context,
                        "Email requirements",
                        "• Must be a valid email\n• Example: name@gmail.com",
                      ),
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
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: canResend
                            ? () => sendReset(isResend: true)
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: canResend
                                ? const Color(0xFFC06797)
                                : Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Resend Code",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
