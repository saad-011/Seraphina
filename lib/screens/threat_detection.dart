import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seraphina/services/location_service.dart';

class ThreatDetection extends StatefulWidget {
  const ThreatDetection({super.key});

  @override
  State<ThreatDetection> createState() => _ThreatDetectionState();
}

class _ThreatDetectionState extends State<ThreatDetection> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isProcessingChunk = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
  }

  Future<String> _getNewFilePath() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/chunk_$timestamp.aac';
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    setState(() => _isRecording = true);
    _recordAndLoop();
  }

  Future<void> _recordAndLoop() async {
    while (_isRecording) {
      await _recordNextChunk();
    }
  }

  Future<void> _recordNextChunk() async {
    if (!_isRecording || _isProcessingChunk) return;
    _isProcessingChunk = true;

    try {
      final path = await _getNewFilePath();

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
      );

      await Future.delayed(const Duration(seconds: 10));
      await _recorder.stopRecorder();

      if (kDebugMode) {
        print('Chunk recorded: $path');
      }

      await _sendToServer(path);
    } catch (e) {
      if (kDebugMode) print("Recording error: $e");
    } finally {
      _isProcessingChunk = false;
    }
  }

  Future<void> _sendToServer(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.67:5000/upload'),  // Correct URL here
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (kDebugMode) print("Uploaded: $filePath - Response: $responseString");

        // Parse the response (assuming JSON response from server)
        final responseJson = jsonDecode(responseString);
        final prediction = responseJson['prediction'];

        // Check the prediction result
        if (prediction == 1) {
          // Threat detected (Scream detected)
          if (kDebugMode) print("🚨 Threat Detected, Triggering SOS!");
          _sendSOSAlert();
        } else {
          // No threat detected, keep checking
          if (kDebugMode) print("No scream detected. Continuing monitoring...");
        }
      } else {
        if (kDebugMode) print("Failed upload: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) print("Upload error: $e");
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _isRecording = false);

    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }

    if (kDebugMode) print("Recording stopped.");
  }

  bool _isSendingSOS = false;

  Future<void> _sendSOSAlert() async {
    setState(() => _isSendingSOS = true);

    await LocationService.sendAlert("SOS");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 SOS Alert Sent Successfully!")),
      );
    }

    setState(() => _isSendingSOS = false);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
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
                    "Threat Detection",
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
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.mic, size: 150, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: _isRecording ? null : _startRecording,
              child: const Text(
                "Start Audio Monitoring",
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text(
                "Stop recording",
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}