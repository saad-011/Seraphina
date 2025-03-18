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
  Set<String> _selectedContacts = {}; // Stores "Name:Number"
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
    }

    setState(() {
      _contacts = contacts.toList();
      _selectedContacts = savedContacts.toSet(); // Convert List to Set
      _isLoading = false;
    });
  }

  void _toggleContactSelection(Contact contact) {
    if (contact.phones!.isEmpty) return; // Ignore contacts without numbers

    String contactEntry = "${contact.displayName}:${contact.phones!.first.value}";

    setState(() {
      if (_selectedContacts.contains(contactEntry)) {
        _selectedContacts.remove(contactEntry);
      } else {
        if (_selectedContacts.length < 5) {
          _selectedContacts.add(contactEntry);
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
          title: const Text("Limit Reached"),
          content: const Text("You can only select a maximum of 5 SOS contacts."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> contactsToSave = _selectedContacts.toList();

    if (kDebugMode) {
      print("Saving SOS Contacts: $contactsToSave");
    }

    await prefs.setStringList('selectedSOSContacts', contactsToSave);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select SOS Contacts", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D2A3C),
      ),
      body: Container(
        color: const Color(0xFF80a6eb),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            String contactEntry = "${contact.displayName}:${contact.phones!.isNotEmpty ? contact.phones!.first.value : 'No Number'}";
            final isSelected = _selectedContacts.contains(contactEntry);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                tileColor: Colors.white,
                title: Text(contact.displayName ?? "No Name"),
                subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ?? "No Number" : "No Number"),
                trailing: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? Colors.green : null,
                ),
                onTap: () => _toggleContactSelection(contact),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelectedContacts,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.save, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
