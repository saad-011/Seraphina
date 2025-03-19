import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seraphina/screens/fake_call.dart';
import 'package:seraphina/screens/signin_screen.dart';
import 'package:seraphina/screens/sos_alert.dart';
import 'package:seraphina/screens/location_sharing.dart';
import 'package:seraphina/screens/threat_detection.dart';
import 'package:seraphina/screens/setting_screen.dart';
import 'package:seraphina/screens/contacts_screen.dart';
import 'package:seraphina/screens/helplines_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected tab
  DateTime? _lastPressed; // Track last back button press time

  final List<Widget> _pages = [
    const HomeContent(),
    const HelplinesScreen(),
    const ContactsScreen(),
    const SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }

    DateTime now = DateTime.now();
    if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0D2A3C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex, // Highlight the selected tab
          onTap: _onItemTapped, // Change page on tap
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Helplines',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Extracted Home Page UI into a separate StatelessWidget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF80A6EB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            logoWidget("assets/images/logo.png"),
            const SizedBox(height: 5),
            const Text(
              'Seraphina',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Cursive',
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  featureCard(
                    label: 'Threat Detection',
                    icon: Icons.security,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ThreatDetection())),
                  ),
                  featureCard(
                    label: 'Fake Call',
                    icon: Icons.phone,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCall())),
                  ),
                  featureCard(
                    label: 'Live Location',
                    icon: Icons.location_pin,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationSharing())),
                  ),
                  featureCard(
                    label: 'SOS Alert',
                    icon: Icons.notification_important_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SOSAlert())),
                  ),
                ],
              ),
            ),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30),
              child: ElevatedButton(
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2A3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget logoWidget(String imageName) {
    return Image.asset(
      imageName,
      width: 150,
      height: 150,
    );
  }

  Widget featureCard({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF0D2A3C),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}