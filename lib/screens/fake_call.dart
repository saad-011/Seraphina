import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:seraphina/screens/incoming_call.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fake Call Simulator',
      home: FakeCall(),
    );
  }
}

class FakeCall extends StatefulWidget {
  const FakeCall({Key? key}) : super(key: key);

  @override
  State<FakeCall> createState() => _FakeCallState();
}

class _FakeCallState extends State<FakeCall> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  TextEditingController myController = TextEditingController();
  final List<String> items = ['Male', 'Female']; // Gender selection
  String? selectedValue = 'Male'; // Default gender selection
  final List<String> language = ['English', 'Urdu']; // Language options
  String? selectedLang = 'Urdu'; // Selected language
  TimeOfDay? selectedTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    myController.dispose();
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });

      _scheduleFakeCall(selectedTime!);
    }
  }

  void _scheduleFakeCall(TimeOfDay selectedTime) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    Duration delay = selectedDateTime.difference(now);

    if (delay.isNegative) {
      // If the selected time is in the past, schedule for the next day
      delay += const Duration(days: 1);
    }

    timer?.cancel(); // Cancel any existing timers
    timer = Timer(delay, () {
      _triggerFakeCall();
    });

    _showScheduledCallDialog(
      selectedTime.format(context),
      myController.text,
      selectedLang ?? 'Unknown',
    );
  }

  void _triggerFakeCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCall(
          value: myController.text,
          selectedGender: selectedValue!,
          selectedLang: selectedLang!,
        ),
      ),
    );
  }

  void _showScheduledCallDialog(String time, String name, String language) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fake Call Scheduled"),
          content: Text("Fake Call is scheduled at $time from $name in $language."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fake Call Simulator', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0D2A3C),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.pink,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Call Now'),
              Tab(text: 'Schedule Call'),
            ],
          ),
        ),
        body: TabBarView(
            children: [
        // Call Now Tab
        SingleChildScrollView(
        child: Container(
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF80a6eb),
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png', width: 200),
            const SizedBox(height: 40),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                fillColor: Colors.white.withOpacity(0.8),
                filled: true,
                hintText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                fillColor: Colors.white.withOpacity(0.8),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedLang,
              decoration: InputDecoration(
                fillColor: Colors.white.withOpacity(0.8),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: language.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedLang = value;
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFF54184),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Call Now'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncomingCall(
                      value: myController.text,
                      selectedGender: selectedValue!,
                      selectedLang: selectedLang!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    // Schedule Call Tab
    SingleChildScrollView(
      child: Container(
          height: MediaQuery.of(context).size.height,
          color: const Color(0xFF80a6eb),
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
          child: Column(
            children: [
                Image.asset('assets/images/logo.png', width: 200),
                const SizedBox(height: 20),
                TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    hintText: 'Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedValue,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedValue = value;
                    });
                    },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedLang,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: language.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                          selectedLang = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    // Button for time selection
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Color(0xFFBEBEBE),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: Text(selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${selectedTime!.format(context)}'),
                    ),
                    SizedBox(height: 10),
                    // Button to schedule the call
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFFF54184),
                        padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text('Schedule Call'),
                      onPressed: () => _scheduleFakeCall(context as TimeOfDay),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}