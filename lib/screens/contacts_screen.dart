import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seraphina/screens/contact_selection.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<String> _selectedSOSContacts = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedContacts();
  }

  void _loadSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedContacts = prefs.getStringList('selectedSOSContacts');
    if (savedContacts != null) {
      setState(() {
        _selectedSOSContacts = savedContacts;
      });
    }
  }

  void _navigateToSelectionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactSelection()),
    );
    _loadSelectedContacts();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A3C),
        centerTitle: true,
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFF80a6eb),
        child: _selectedSOSContacts.isEmpty
            ? const Center(
          child: Text(
            "No Emergency Contacts Selected",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        )
            : ListView.builder(
          itemCount: _selectedSOSContacts.length,
          itemBuilder: (context, index) {
            final contactData = _selectedSOSContacts[index].split(':');
            final contactName = contactData[0].trim();
            final contactNumber = contactData.length > 1 ? contactData[1].trim() : "No Number";

            return Card(
              color: const Color(0xFF034D7E), // Dark blue card background
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  contactName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  contactNumber,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: Colors.white),
                  onPressed: () => _makePhoneCall(contactNumber),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: _navigateToSelectionScreen,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
