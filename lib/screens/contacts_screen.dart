import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Set<String> _selectedSOSContacts = <String>{};
  bool _isLoading = true;
  bool _showSOSContacts = true; // Toggle between SOS and all contacts
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadContacts();
    _searchController.addListener(_filterContacts);
    _loadSelectedContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  void _checkPermissionsAndLoadContacts() async {
    if (await _requestPermissions()) {
      _loadContacts();
    } else {
      setState(() => _isLoading = false);
      if (kDebugMode) {
        print('Contact permission not granted');
      }
    }
  }

  void _loadContacts() async {
    Iterable<Contact> contacts =
    await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      _contacts = contacts.toList();
      _filteredContacts = _contacts;
      _isLoading = false;
    });
  }

  void _loadSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedContactIds =
    prefs.getStringList('selectedSOSContacts');
    if (savedContactIds != null) {
      setState(() {
        _selectedSOSContacts = savedContactIds.toSet();
      });
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final contactName = contact.displayName?.toLowerCase() ?? '';
        return contactName.contains(query);
      }).toList();
    });
  }

  void _toggleContactSelection(String contactId) {
    if (_showSOSContacts) {
      // SOS Mode: Limit to 5 contacts
      if (_selectedSOSContacts.contains(contactId)) {
        setState(() {
          _selectedSOSContacts.remove(contactId);
        });
      } else {
        if (_selectedSOSContacts.length < 5) {
          setState(() {
            _selectedSOSContacts.add(contactId);
          });
        } else {
          _showMaxSelectionError();
        }
      }
    } else {
      // Location sharing: No selection limit, open share dialog
      _shareLocation(contactId);
    }
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

  void _shareLocation(String contactId) {
    // TODO: Implement location sharing logic
    if (kDebugMode) {
      print("Sharing location with: $contactId");
    }
  }

  void _saveSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedSOSContacts', _selectedSOSContacts.toList());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showSOSContacts ? 'Select SOS Contacts' : 'Share Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _showSOSContacts ? _saveSelectedContacts : null,
          ),
        ],
        backgroundColor: Color(0xff48032f),
      ),
      body: Column(
        children: [
          ToggleButtons(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('SOS Contacts'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('All Contacts'),
              ),
            ],
            isSelected: [_showSOSContacts, !_showSOSContacts],
            onPressed: (int index) {
              setState(() {
                _showSOSContacts = index == 0;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                final isSelected = _selectedSOSContacts.contains(contact.identifier);
                return ListTile(
                  title: Text(contact.displayName ?? 'No Name'),
                  trailing: _showSOSContacts
                      ? Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected ? Color(0xFFF54184) : null,
                  )
                      : Icon(Icons.location_on, color: Colors.blue),
                  onTap: () => _toggleContactSelection(contact.identifier ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
