import 'package:flutter/material.dart';
import 'package:seraphina/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seraphina/screens/home_screen.dart';

class HelplinesScreen extends StatefulWidget {
  const HelplinesScreen({super.key});

  @override
  State<HelplinesScreen> createState() => _HelplinesScreenState();
}

class _HelplinesScreenState extends State<HelplinesScreen> {
  String selectedCity = 'Lahore';
  List<Map<String, String>> allHelplines = [];
  List<Map<String, String>> filteredHelplines = [];
  final TextEditingController _searchController = TextEditingController();

  final Map<String, List<Map<String, String>>> cityHelplines = {

    'Lahore': [
      {'name': 'Edhi Ambulance', 'number': '042-115'},
      {'name': 'Jinnah Hospital', 'number': '042-35928231'},
      {'name': 'Punjab Police', 'number': '15'},
      {'name': 'Madadgar', 'number': '1098'},
      {'name': 'Women Toll Free Helpline', 'number': '1043'},
      {'name': 'Rescue 1122', 'number': '1122'},
      {'name': 'Fire Brigade', 'number': '16'},
      {'name': 'Aurat Foundation Lahore', 'number': '+92-042-36286296'},

    ],
    'Karachi': [
      {'name': 'Edhi Ambulance', 'number': '021-115'},
      {'name': 'Aga Khan Hospital', 'number': '021-3493 0051'},
    ],
    'Peshawar': [
      {'name': 'Edhi Ambulance', 'number': '091-115'},
      {'name': 'Khyber Teaching Hospital', 'number': '091-9217140-47'},
    ],
    'Islamabad': [
      {'name': 'Edhi Ambulance', 'number': '051-115'},
      {'name': 'Civil Hospital', 'number': '555-0311'},
      {'name': 'Police Emergency', 'number': '051-15'},
      {'name': 'Rescue Service', 'number': '051-1122'},
      {'name': 'Aurat Foundation', 'number': '051-26089568'},
      {'name': 'Madadgar', 'number': '111-9111-922'},
      {'name': 'ROZAN', 'number': '051-2890505-7'},
      {'name': 'Fire Brigade', 'number': '16'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _updateFilteredHelplines(selectedCity);
  }

  void _updateFilteredHelplines(String city) {
    allHelplines = cityHelplines[city] ?? [];
    _filterHelplines();
  }

  void _filterHelplines() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredHelplines = allHelplines;
    } else {
      filteredHelplines = allHelplines
          .where((helpline) =>
      helpline['name']!.toLowerCase().contains(query) ||
          helpline['number']!.contains(query))
          .toList();
    }
    setState(() {});
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $phoneNumber')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D2A3C),
        title: Text('Helplines', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  helplines: allHelplines,
                  searchFunction: _makePhoneCall,
                ),
              );
            },
          ),
        ],
      ),


      body: Container(
        color: const Color(0xFF80a6eb),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Color(0xff109CCD),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  dropdownColor: Color(0xFF3F4D55),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  elevation: 16,
                  style: TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCity = newValue;
                        _updateFilteredHelplines(newValue);
                      });
                    }
                  },
                  items: cityHelplines.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Helpline list
            Expanded(
              child: ListView.builder(
                itemCount: filteredHelplines.length,
                itemBuilder: (context, index) {
                  final helpline = filteredHelplines[index];
                  return Card(
                    color: Color(0xFF034D7E),
                    child: ListTile(
                      title: Text(helpline['name'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      subtitle: Text(helpline['number'] ?? '',
                          style: TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: Icon(Icons.phone, color: Colors.white),
                        onPressed: () => _makePhoneCall(helpline['number']!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Search Delegate
class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> helplines;
  final Function(String) searchFunction;

  CustomSearchDelegate({required this.helplines, required this.searchFunction});

  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: Color(0xFF80a6eb),
      appBarTheme: AppBarTheme(backgroundColor: Color(0xFF0D2A3C)),
      inputDecorationTheme:
      InputDecorationTheme(hintStyle: TextStyle(color: Colors.white)),
      textTheme:
      theme.textTheme.copyWith(titleLarge: TextStyle(color: Colors.white)),
      iconTheme: IconThemeData(color: Colors.white),
    );
  }


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    final results = helplines
        .where((helpline) =>
    helpline['name']!.toLowerCase().contains(query.toLowerCase()) ||
        helpline['number']!.contains(query))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var result = results[index];
        return ListTile(
          title: Text(result['name'] ?? '', style: TextStyle(color: Colors.black)),
          subtitle:
          Text(result['number'] ?? '', style: TextStyle(color: Colors.black)),
          trailing: Icon(Icons.phone, color: Colors.black),
          onTap: () => searchFunction(result['number']!),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
