import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../services/session.dart';
import 'forgotpass.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirm = false;

  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

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

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Future<void> loginUser() async {
    if (emailCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
      showToast("Email and password are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await AuthService().login(
        emailCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      if (res != null && res.statusCode == 200) {
        final token = res.data['token'];
        final user = res.data['user'];

        await Session.saveLogin(
          token: token,
          userId: user['id'],
          email: user['email'],
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showToast("Invalid email or password");
      }
    } catch (e) {
      showToast("Login failed. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signupUser() async {
    if (nameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty ||
        passwordCtrl.text.trim().isEmpty) {
      showToast("All fields are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await AuthService().signup(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        phoneCtrl.text.trim(),
        passwordCtrl.text.trim(),
        "user",
      );

      if (res != null) {
        showToast("Account created successfully");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      showToast("Signup failed. Email may already exist.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
            const SizedBox(height: 60),

            /// LOGO
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 46,
                    height: 46,
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
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// CARD
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    /// TOGGLE
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            alignment: isLogin
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isLogin
                                            ? const Color(0xFFC06797)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: Center(
                                    child: Text(
                                      "Signup",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !isLogin
                                            ? const Color(0xFFC06797)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FORM
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isLogin ? loginForm() : signupForm(),
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

  /// LOGIN FORM
  Widget loginForm() {
    return Column(
      key: const ValueKey("login"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label("Email"),
        TextField(
          controller: emailCtrl,
          decoration: inputStyle("Enter your email"),
        ),
        const SizedBox(height: 16),

        label("Password"),
        TextField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          decoration: inputStyle(
            "Enter your password",
            suffix: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
              );
            },
            child: const Text(
              "Forgot password?",
              style: TextStyle(color: Color(0xFFC06797)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : loginUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC06797),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(isLoading ? "Logging in..." : "Login"),
          ),
        ),
      ],
    );
  }

  /// SIGNUP FORM
  Widget signupForm() {
    return Column(
      key: const ValueKey("signup"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label("Full Name"),
        TextField(
          controller: nameCtrl,
          decoration: inputStyle("Enter your name"),
        ),
        const SizedBox(height: 16),

        label("Email"),
        TextField(
          controller: emailCtrl,
          decoration: inputStyle("Enter your email"),
        ),
        const SizedBox(height: 16),

        label("Phone"),
        TextField(
          controller: phoneCtrl,
          decoration: inputStyle("Enter your phone"),
        ),
        const SizedBox(height: 16),

        label("Password"),
        TextField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          decoration: inputStyle(
            "Create password",
            suffix: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
          ),
        ),

        const SizedBox(height: 20),

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
            child: Text(isLoading ? "Creating account..." : "Create Account"),
          ),
        ),
      ],
    );
  }
}
