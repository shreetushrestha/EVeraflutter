import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';

class WebManagerLogin extends StatefulWidget {
  const WebManagerLogin({super.key});

  @override
  State<WebManagerLogin> createState() => _WebManagerLoginState();
}

class _WebManagerLoginState extends State<WebManagerLogin> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool showPassword = false;
  bool isLogin = true; // Toggle between login/signup

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0x337EC090), // 20% opacity of 67C090
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
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

  void loginManager() async {
    setState(() => loading = true);

    final res = await AuthService().login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (res != null && res.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/mystation');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'label': 'Active Stations',
        'value': '15,000+',
        'color': Colors.yellow.shade600,
      },
      {
        'label': 'Uptime Rate',
        'value': '98.5%',
        'color': Colors.green.shade400,
      },
      {
        'label': 'EV Drivers',
        'value': '50,000+',
        'color': Colors.blue.shade400,
      },
      {
        'label': 'Energy Delivered',
        'value': '2.5M kWh',
        'color': Colors.purple.shade400,
      },
    ];

    return Scaffold(
      body: Row(
        children: [
          // LEFT LANDING HERO
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.4)),
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/logo.svg',
                              width: 40,
                              height: 40,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF67C090),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'EVera',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      const Text(
                        'Manage Your EV Charging Stations Effortlessly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: stats.map((s) {
                          return Container(
                            width: 140,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: s['color'] as Color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s['value'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  s['label'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // RIGHT FORM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle Login / Signup
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6E6E6),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isLogin = true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isLogin
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
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
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isLogin = false),
                                child: Container(
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
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form Fields
                      if (isLogin) ...[
                        fieldLabel("Email"),
                        TextField(
                          controller: emailController,
                          decoration: inputStyle("Enter your email"),
                        ),
                        const SizedBox(height: 18),

                        fieldLabel("Password"),
                        TextField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0x337EC090),
                            hintText: "Enter your password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => showPassword = !showPassword),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loginManager,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC06797),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Signup form placeholder
                        fieldLabel("Full Name"),
                        TextField(
                          decoration: inputStyle("Enter your full name"),
                        ),
                        const SizedBox(height: 18),

                        fieldLabel("Email"),
                        TextField(decoration: inputStyle("Enter your email")),
                        const SizedBox(height: 18),

                        fieldLabel("Phone"),
                        TextField(decoration: inputStyle("Enter your phone")),
                        const SizedBox(height: 18),

                        fieldLabel("Company Name"),
                        TextField(
                          decoration: inputStyle("Enter your company name"),
                        ),
                        const SizedBox(height: 18),

                        fieldLabel("Primary Station"),
                        TextField(
                          decoration: inputStyle("Enter primary station"),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC06797),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Signup",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
