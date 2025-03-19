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
  List<Contact> _filteredContacts = [];
  Set<String> _selectedContacts = {}; // Stores "Name:Number"
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadContacts();

    _searchController.addListener(() {
      _filterContacts();
    });
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
      _filteredContacts = _contacts;
      _selectedContacts = savedContacts.toSet(); // Convert List to Set
      _isLoading = false;
    });
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) =>
      (contact.displayName ?? "").toLowerCase().contains(query) ||
          (contact.phones!.isNotEmpty &&
              contact.phones!.first.value!.contains(query)))
          .toList();
    });
  }

  void _toggleContactSelection(Contact contact) {
    if (contact.phones!.isEmpty) return;

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
          content: const Text("You can only select a maximum of 5 Emergency contacts."),
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
        title: const Text(
          "Select Contacts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D2A3C),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(_contacts, _toggleContactSelection, _selectedContacts),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF80a6eb),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = _filteredContacts[index];
            String contactEntry =
                "${contact.displayName}:${contact.phones!.isNotEmpty ? contact.phones!.first.value : 'No Number'}";
            final isSelected = _selectedContacts.contains(contactEntry);

            return Card(
              color: const Color(0xFF034D7E),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  contact.displayName ?? "No Name",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  contact.phones!.isNotEmpty ? contact.phones!.first.value ?? "No Number" : "No Number",
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? Colors.green : Colors.white,
                ),
                onTap: () => _toggleContactSelection(contact),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          onPressed: _saveSelectedContacts,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.save, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final List<Contact> contacts;
  final Function(Contact) toggleSelection;
  final Set<String> selectedContacts;

  ContactSearchDelegate(this.contacts, this.toggleSelection, this.selectedContacts);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D2A3C),
        iconTheme: IconThemeData(color: Colors.white),
        toolbarTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // inputDecorationTheme: const InputDecorationTheme(
      //   filled: true,
      //   fillColor: Color(0xFF034D7E), // Background color for search bar
      //   hintStyle: TextStyle(color: Colors.white70), // Hint text color
      //   border: OutlineInputBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(10)),
      //     borderSide: BorderSide.none, // Remove default border
      //   ),
      //   contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildContactList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildContactList();
  }

  Widget buildContactList() {
    final List<Contact> filteredContacts = contacts
        .where((contact) =>
    (contact.displayName ?? "").toLowerCase().contains(query.toLowerCase()) ||
        (contact.phones!.isNotEmpty && contact.phones!.first.value!.contains(query)))
        .toList();

    return Container(
      color: const Color(0xFF80a6eb), // Maintain background color
      child: ListView.builder(
        itemCount: filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = filteredContacts[index];
          String contactEntry =
              "${contact.displayName}:${contact.phones!.isNotEmpty ? contact.phones!.first.value : 'No Number'}";
          final isSelected = selectedContacts.contains(contactEntry);

          return Card(
            color: const Color(0xFF034D7E),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(contact.displayName ?? "No Name", style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                contact.phones!.isNotEmpty ? contact.phones!.first.value ?? "No Number" : "No Number",
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? Colors.green : Colors.white,
              ),
              onTap: () => toggleSelection(contact),
            ),
          );
        },
      ),
    );
  }
}
