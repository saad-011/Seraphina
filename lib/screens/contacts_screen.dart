import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadSelectedContacts(); // Reload contacts after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2A3C),
        centerTitle: true, // Center title
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _selectedSOSContacts.isEmpty
          ? const Center(child: Text("No Emergency Contacts Selected"))
          : ListView.builder(
        itemCount: _selectedSOSContacts.length,
        itemBuilder: (context, index) {
          final contactData = _selectedSOSContacts[index].split(':');
          final contactName = contactData[0].trim();
          final contactNumber = contactData.length > 1 ? contactData[1].trim() : "No Number";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              tileColor: Colors.white,
              leading: const Icon(Icons.phone, color: Colors.red),
              title: Text(contactName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(contactNumber, style: const TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0), // Adjust button above bottom nav bar
        child: FloatingActionButton(
          onPressed: _navigateToSelectionScreen,
          backgroundColor: const Color(0xFF0D2A3C),
          child: const Icon(Icons.add, color: Colors.white), // "+" icon
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // Positioned in bottom-right
    );
  }
}
