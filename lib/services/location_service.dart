import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class LocationService {
  static final Telephony telephony = Telephony.instance;

  /// Get the current live location of the user
  static Future<String?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // Return null to indicate failure
    }

    // Check location permissions
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
      return "https://www.google.com/maps?q=${position.latitude},${position.longitude}";
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
      return null;
    }
  }

  /// Send SOS alert with live location to emergency contacts
  static Future<void> sendSOSAlert() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emergencyContacts = prefs.getStringList('selectedSOSContacts') ?? [];

    if (emergencyContacts.isEmpty) {
      if (kDebugMode) {
        print("No emergency contacts saved.");
      }
      return;
    }

    // Request SMS permissions
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == false) {
      if (kDebugMode) {
        print("SMS permissions denied.");
      }
      return;
    }

    String? location = await getCurrentLocation();
    String message = "🚨 Emergency Alert! 🚨\nI need help! My live location: $location";

    for (String contact in emergencyContacts) {
      try {
        telephony.sendSms(
          to: contact,
          message: message,
        );
        if (kDebugMode) {
          print("✅ SOS alert sent to $contact");
        }
      } catch (e) {
        if (kDebugMode) {
          print("❌ Failed to send SOS alert to $contact: $e");
        }
      }
    }
  }

}
