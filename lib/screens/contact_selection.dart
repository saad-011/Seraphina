import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactSelection extends StatefulWidget {
  const ContactSelection({super.key});

  @override
  State<ContactSelection> createState() => _ContactSelectionState();
}

class _ContactSelectionState extends State<ContactSelection> {
  List<Contact> _contacts = [];
  Set<String> _selectedContacts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadContacts();
  }

  Future<void> _checkPermissionsAndLoadContacts() async {
    if (await Permission.contacts.request().isGranted) {
      _loadContacts();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedContacts = prefs.getStringList('selectedSOSContacts') ?? [];

    if (kDebugMode) {
      print("Loaded SOS Contacts: $savedContacts");
    } // Debugging log

    setState(() {
      _contacts = contacts.toList();
      _selectedContacts = savedContacts.toSet(); // Convert List to Set
      _isLoading = false;
    });
  }


  void _toggleContactSelection(String contactName) {
    setState(() {
      if (_selectedContacts.contains(contactName)) {
        _selectedContacts.remove(contactName);
      } else {
        if (_selectedContacts.length < 5) {
          _selectedContacts.add(contactName);
        } else {
          _showMaxSelectionError();
        }
      }
    });
  }

  void _showMaxSelectionError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Limit Reached"),
          content: Text("You can only select a maximum of 5 SOS contacts."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> contactsToSave = _selectedContacts.toList(); // Ensure it's a List

    if (kDebugMode) {
      print("Saving SOS Contacts: $contactsToSave");
    } // Debugging log

    await prefs.setStringList('selectedSOSContacts', contactsToSave);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select SOS Contacts", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveSelectedContacts,
          ),
        ],
        backgroundColor: Color(0xFF0D2A3C),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          final isSelected = _selectedContacts.contains(contact.displayName);
          return ListTile(
            title: Text(contact.displayName ?? "No Name"),
            trailing: Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? Colors.green : null,
            ),
            onTap: () => _toggleContactSelection(contact.displayName ?? ''),
          );
        },
      ),
    );
  }
}
