import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final companyController = TextEditingController();
  final stationController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  InputDecoration inputStyle(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F6F4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  void signupUser() async {
    setState(() => isLoading = true);

    try {
      await AuthService().signup(
        nameController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        passwordController.text.trim(),
        stationController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67C090),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),

            /// LOGO
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 52,
                    height: 52,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF67C090),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "EVera",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            /// CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOGGLE
                  Center(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Signup",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFC06797),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushReplacementNamed(context, '/login'),
                              child: const Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFC06797),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  fieldLabel("Full Name"),
                  TextField(
                    controller: nameController,
                    decoration: inputStyle("Enter your full name"),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Email"),
                  TextField(
                    controller: emailController,
                    decoration: inputStyle("Enter your email"),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Phone Number"),
                  TextField(
                    controller: phoneController,
                    decoration: inputStyle("Enter your phone number"),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Company Name"),
                  TextField(
                    controller: companyController,
                    decoration: inputStyle("Enter your company name"),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Primary Station Location"),
                  TextField(
                    controller: stationController,
                    decoration: inputStyle("City, State"),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Password"),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: inputStyle(
                      "Create a password",
                      suffix: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  fieldLabel("Confirm Password"),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    decoration: inputStyle(
                      "Re-enter password",
                      suffix: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => isConfirmPasswordVisible =
                              !isConfirmPasswordVisible,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC06797),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLoading ? "Creating account..." : "Create Account",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
