import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Macau Bus Quick Check',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> _data = [];
  List<List<dynamic>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/csv/bus_list.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData.sublist(1); // Assuming the first row is header
      _filteredData = _data;
    });
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((row) =>
              row[0].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macau Bus Quick Check'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Bus ID',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterData,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Text(_filteredData[index][0].toString()),
                  onTap: () {
                    _launchURL(_filteredData[index][1].toString());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
