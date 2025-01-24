import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:seraphina/screens/call_page.dart';


class IncomingCall extends StatefulWidget {
  final String value;
  final String? selectedGender;
  final String? selectedLang;

  const IncomingCall(
      {super.key,
        required this.value,
        required this.selectedGender,
        required this.selectedLang});

  @override
  State<IncomingCall> createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  late String selectedLang = "${widget.selectedLang}";
  late String Name = widget.value;
  late String gender = "${widget.selectedGender}";
  late AudioPlayer audioPlayer;
  String areaCode = "+92";
  String prefix = "30";
  var LastFour = Random().nextInt(10000000) + 9999999;

  var player;
  bool ringing = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    audioPlayer = AudioPlayer(); // Initialize the audio player
    playRingtone(); // Call this method to play the ringtone
  }

 void playRingtone() async {
    try {
      await audioPlayer.play(AssetSource('audio/iphone.mp3'));
      if (kDebugMode) {
        print("Playing audio");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Could not load the audio: $e");
      }
    }
  }

  @override
  void dispose() {
    //audioPlayer.dispose(); // Dispose of the player when the widget is disposed
    super.dispose();
  }

  void stopRingtone() async {
    await audioPlayer.stop();
    setState(() {
      ringing = false;
    });
  }

  void answerCall() {
    stopRingtone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50),
              ),
              Text(
                "$areaCode-$prefix$LastFour",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.alarm, color: Colors.white, size: 30),
                      Text("Remind Me"),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.message, color: Colors.white, size: 30),
                      Text("Message"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          onPressed: () {
                            stopRingtone();
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 1);
                          },
                          child: Icon(Icons.call_end, size: 34),
                        ),
                      ),
                      Text("Decline"),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        child: FloatingActionButton(
                          backgroundColor: Colors.green,
                          onPressed: () {

                            answerCall();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CallPage(
                                      name: Name,
                                      genderSelection: gender,
                                      areaCode: areaCode,
                                      prefix: prefix,
                                      lastFour: LastFour,
                                      Lang: selectedLang,
                                    )));
                          },
                          child: Icon(Icons.phone, size: 34),
                        ),
                      ),
                      Text("Accept"),
                    ],
                  )
                ],
              ),
              SizedBox(height: 60),
            ],
          )
        ],
      ),
    );
  }
}
