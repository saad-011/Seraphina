import 'package:flutter/material.dart';
import 'package:seraphina/services/location_service.dart';

class LocationSharing extends StatefulWidget {
  const LocationSharing({super.key});

  @override
  State<LocationSharing> createState() => _LocationSharingState();
}

class _LocationSharingState extends State<LocationSharing> {
  String _currentLocation = "Fetching location...";
  bool _isLoadingLocation = false;
  bool _isSendingSOS = false;

  Future<void> _updateLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    String? location = await LocationService.getCurrentLocation();

    setState(() {
      _currentLocation = location ?? "⚠️ Unable to fetch location. Check GPS settings.";
      _isLoadingLocation = false;
    });
  }

  Future<void> _sendLocation() async {
    setState(() {
      _isSendingSOS = true;
    });

    await LocationService.sendAlert("Location");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Location shared successfully!")),
      );
    }

    setState(() {
      _isSendingSOS = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7AB6F9), Color(0xFF1E3A8A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 15),
              color: const Color(0xFF0D2A3C),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Location Sharing",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Seraphina",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Cursive'),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.location_on, size: 150, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _currentLocation,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: _isLoadingLocation ? null : _updateLocation,
              child: _isLoadingLocation
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Refresh Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: _isSendingSOS ? null : _sendLocation,
              child: _isSendingSOS
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Send Live Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ],
        ),
      ),

    );
  }
}
