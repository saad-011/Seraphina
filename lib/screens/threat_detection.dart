import 'package:flutter/material.dart';

class ThreatDetection extends StatefulWidget {
  const ThreatDetection({super.key});

  @override
  State<ThreatDetection> createState() => _ThreatDetectionState();
}

class _ThreatDetectionState extends State<ThreatDetection> {
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
                  // Back button on the left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  // Centered Title
                  const Text(
                    "Threat Detection",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Title "Seraphina"
            const Text(
              "Seraphina",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Cursive',
              ),
            ),

            const SizedBox(height: 40),

            // Microphone Icon
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.mic,
                size: 150,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),

            // Start Recording Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: () {
                // TODO: Implement start recording function
              },
              child: const Text(
                "Start Continuous Audio Recording",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Stop Recording Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: () {
                // TODO: Implement stop recording function
              },
              child: const Text(
                "Stop recording",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
