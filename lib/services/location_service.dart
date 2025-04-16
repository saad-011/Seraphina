import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';

class LocationService {
  static final Telephony telephony = Telephony.instance;

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
      return "www.google.com/maps?q=${position.latitude},${position.longitude}";
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location: $e");
      }
      return null;
    }
  }

  static Future<void> sendAlert(String messageType) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emergencyContacts = prefs.getStringList('selectedSOSContacts') ?? [];

    if (emergencyContacts.isEmpty) {
      if (kDebugMode) print("No emergency contacts saved.");
      return;
    }

    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == false) {
      if (kDebugMode) print("SMS permissions denied.");
      return;
    }

    // Ensure location is not null
    String? location = await getCurrentLocation();
    location ??= "Location unavailable.";

    // Construct message
    String message;
    if (messageType == "SOS") {
      message = "🚨 Emergency Alert! 🚨  $location";
    } else if (messageType == "Location") {
      message = "📍 Location Shared: $location";
    } else {
      if (kDebugMode) print("❌ Invalid message type: $messageType");
      return;
    }


    for (String contact in emergencyContacts) {
      try {
        if (kDebugMode) print("Final SMS message: $message");
        telephony.sendSms(
          to: contact,
          message: message,
        );
        if (kDebugMode) print("✅ $messageType alert sent to $contact");
      } catch (e) {
        if (kDebugMode) print("❌ Failed to send $messageType alert to $contact: $e");
      }
    }
  }
}