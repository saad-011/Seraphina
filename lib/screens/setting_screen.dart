import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seraphina/screens/home_screen.dart';
import 'package:seraphina/screens/signin_screen.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final String userName = "Zainab Akram";

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingOptions = [
      {
        "title": "Edit Profile",
        "icon": Icons.edit,
        "onTap": () {},
      },
      {
        "title": "Change Password",
        "icon": Icons.lock,
        "onTap": () {},
      },
      {
        "title": "About Us",
        "icon": Icons.info_outline,
        "onTap": () {},
      },
      {
        "title": "Logout",
        "icon": Icons.logout,
        "onTap": () {
          FirebaseAuth.instance.signOut().then((value) {
            if (kDebugMode) {
              print("Signed Out");
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          });
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF9EC5F8),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF0D2A3C),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Big profile icon
          const CircleAvatar(
            radius: 75,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 120, color: Color(0xFF0D3B66)),
          ),
          const SizedBox(height: 12),

          // User name
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3B66),
            ),
          ),

          // Divider line
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Divider(
              color: Colors.black,
              thickness: 2,
            ),
          ),

          // Menu cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: settingOptions.length,
              itemBuilder: (context, index) {
                final option = settingOptions[index];
                return Card(
                  color: const Color(0xFF034D7E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option["icon"], color: Colors.white),
                        const SizedBox(width: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Text(
                            option["title"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ).applyClickHandler(option["onTap"]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper extension to handle row clicks
extension CardTapHandler on Widget {
  Widget applyClickHandler(VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: this,
    );
  }
}