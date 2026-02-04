import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_nav.dart';
import '../services/session.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    final res = await AuthService().getUserById(Session.userId!);

    if (res != null && res.statusCode == 200) {
      setState(() {
        user = res.data['data']; // 🔥 FIX HERE
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      bottomNavigationBar: bottomNav(context, 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),
                const SizedBox(height: 10),
                Text(
                  user!['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user!['email'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              statCard("Total\nBookings", "10"),
              statCard("Completed\nBookings", "8"),
            ],
          ),

          const SizedBox(height: 20),

          section("Personal Information"),
          settingItem(Icons.phone, user!['phone'] ?? "Not Provided"),
          settingItem(Icons.email, user!['email']),

          section("Account"),
          settingItem(Icons.lock, "Change Password"),
          settingItem(Icons.payment, "Payment Methods"),
          settingItem(Icons.settings, "Preferences"),

          section("About"),
          settingItem(Icons.privacy_tip, "Privacy Policy"),
          settingItem(Icons.description, "Terms of Service"),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await Session.clear();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },

            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget settingItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
