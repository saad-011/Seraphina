import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';


class CallPage extends StatefulWidget {
  final String name;
  final String genderSelection;
  final String areaCode;
  final String prefix;
  final int lastFour;
  final String Lang;

  const CallPage({
    super.key,
    required this.name,
    required this.genderSelection,
    required this.areaCode,
    required this.prefix,
    required this.lastFour,
    required this.Lang,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Duration duration = Duration();
  Timer? timer;
  bool audioPlaying = false;
  late AudioPlayer _audioPlayer;
  bool isSpeakerEnabled = true;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    startTimer();
    playAudio();
  }

  // Initialize the audio player
  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        audioPlaying = false;
      });
      if (kDebugMode) {
        print("Playback completed.");
      }
    });
  }

  Future<void> playAudio() async {
    String audioFile = 'audio/';

    if (widget.genderSelection == 'Male') {
      audioFile += 'maleaudio.mp3';
    } else if (widget.genderSelection == 'Female') {
      audioFile += 'femaleaudio.mp3';
    } else {
      if (kDebugMode) {
        print('Invalid gender selection.');
      }
      return;
    }

    try {
      await _audioPlayer.play(AssetSource(audioFile)); // Play the audio file
      setState(() {
        audioPlaying = true;
      });
      if (kDebugMode) {
        print("Playing audio: $audioFile");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error playing audio: $e");
      }
    }
  }

  // Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        audioPlaying = false;
      });
      if (kDebugMode) {
        print("Audio stopped.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping audio: $e");
      }
    }
  }

  // Toggle playback mode (Speaker vs Earpiece)
  void toggleSpeaker() {
    setState(() {
      isSpeakerEnabled = !isSpeakerEnabled; // Toggle the speaker state
    });
    if (isSpeakerEnabled) {
      if (kDebugMode) {
        print("Switched to speaker.");
      }
    } else {
      if (kDebugMode) {
        print("Switched to earpiece.");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player to release resources
    super.dispose();
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "${widget.name}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50),
              ),
              Text(
                "${widget.areaCode}${widget.prefix}${widget.lastFour}",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      buildTime(),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 5.6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.mic_off, color: Colors.white, size: 32),
                      Text("Mute"),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.keyboard_alt_outlined,
                          color: Colors.white, size: 32),
                      Text("keypad"),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: toggleSpeaker,
                        child: Icon(
                          isSpeakerEnabled
                              ? Icons.volume_up_outlined
                              : Icons.hearing,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      Text("Speaker"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.add_call, color: Colors.white, size: 32),
                      Text("Mute"),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.video_call_outlined,
                          color: Colors.white, size: 32),
                      Text("keypad"),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.pause, color: Colors.white, size: 32),
                      Text("Hold"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        child: FloatingActionButton(
                          child: Icon(Icons.call_end, size: 37),
                          backgroundColor: Colors.red,
                          onPressed: () {
                            stopAudio();
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 140),
            ],
          )
        ],
      ),
    );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Text(
      '$minutes:$seconds',
      style: TextStyle(fontSize: 20),
    );
  }
}

