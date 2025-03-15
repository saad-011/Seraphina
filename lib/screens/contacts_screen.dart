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
      MaterialPageRoute(builder: (context) => ContactSelection()),
    );
    _loadSelectedContacts(); // Reload SOS contacts after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOS Contacts", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _navigateToSelectionScreen, // Open selection screen
          ),
        ],
        backgroundColor: Color(0xFF0D2A3C),
      ),
      body: _selectedSOSContacts.isEmpty
          ? Center(child: Text("No SOS Contacts Selected"))
          : ListView.builder(
        itemCount: _selectedSOSContacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_selectedSOSContacts[index]), // Show saved contacts
            leading: Icon(Icons.phone, color: Colors.red),
          );
        },
      ),
    );
  }
}
