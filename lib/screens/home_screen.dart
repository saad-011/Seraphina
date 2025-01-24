import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:seraphina/screens/fake_call.dart';
import 'package:seraphina/screens/signin_screen.dart';
import 'package:seraphina/screens/sos_alert.dart';
import 'package:seraphina/screens/location_sharing.dart';
import 'package:seraphina/screens/threat_detection.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFF80A6EB),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.07),
            logoWidget("assets/images/logo.png"),
            SizedBox(height: 5),
            Text(
              'Seraphina',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Cursive',
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.all(20),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  featureCard(
                    label: 'Threat Detection',
                    icon: Icons.security,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ThreatDetection())),
                  ),
                  featureCard(
                    label: 'Fake Call',
                    icon: Icons.phone,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FakeCall())),
                  ),
                  featureCard(
                    label: 'Live Location',
                    icon: Icons.location_pin,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSharing())),
                  ),
                  featureCard(
                    label: 'SOS Alert',
                    icon: Icons.notification_important_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SosAlert())),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D2A3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: Text("Logout",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF0D2A3C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
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
          boxShadow: [
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
              color: Color(0xFF0D2A3C),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}