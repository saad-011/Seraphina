import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Telephony telephony = Telephony.instance;

  static Future<String?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return "https://www.google.com/maps?q=${position.latitude},${position
          .longitude}";
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
      return null;
    }
  }

  Future<void> sendSms() async {
    String? location = await getCurrentLocation();
    String locationMessage = location ?? "Location unavailable.";
    String message = "📍 Location Shared: Here is my current location: $locationMessage";
    telephony.sendSms(
      to: "+923354292366",
      message: "Hello from another_telephony!",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: ElevatedButton(
          onPressed: sendSms,
          child: const Text("Send SMS"),
        ),
      ),
    );
  }
}