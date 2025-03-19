import 'package:flutter/material.dart';
import 'package:seraphina/services/location_service.dart';

class SOSAlert extends StatefulWidget {
  const SOSAlert({super.key});

  @override
  State<SOSAlert> createState() => _SOSAlertState();
}

class _SOSAlertState extends State<SOSAlert> {
  bool _isSendingSOS = false;

  Future<void> _sendSOSAlert() async {
    setState(() {
      _isSendingSOS = true;
    });

    await LocationService.sendAlert("SOS");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 SOS Alert Sent Successfully!")),
      );
    }

    setState(() {
      _isSendingSOS = false;
    });
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
                    "SOS Alert",
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
              child: const Icon(Icons.warning_rounded, size: 150, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "🚨 Press the button below to send an SOS alert to your emergency contacts.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: _isSendingSOS ? null : _sendSOSAlert,
              child: _isSendingSOS
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text("Send SOS Alert", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
