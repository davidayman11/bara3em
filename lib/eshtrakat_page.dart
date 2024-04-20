// ignore_for_file: use_build_context_synchronously, use_super_parameters, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class EshtrakPage extends StatefulWidget {
  const EshtrakPage({Key? key}) : super(key: key);

  @override
  _EshtrakPageState createState() => _EshtrakPageState();
}

class _EshtrakPageState extends State<EshtrakPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _eshtrakStream;
  late TextEditingController _searchController;
  bool _searchEnabled = true;

  @override
  void initState() {
    super.initState();
    _eshtrakStream = _firestore.collection('eshtrakat').snapshots();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eshtrakat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    enabled: _searchEnabled,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _eshtrakStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(document['name'] ?? 'No Name'),
                        subtitle: Text(
                            'Subscription: ${document['subscription'] ?? 'Unknown'}'),
                        onTap: () => _showDetailsDialog(context, document),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _eshtrakStream = _firestore.collection('eshtrakat').snapshots();
      } else {
        _eshtrakStream = _firestore
            .collection('eshtrakat')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .snapshots();
      }
    });
  }

  void _disableSearch(BuildContext context) {
    setState(() {
      _searchController.clear();
      _eshtrakStream = _firestore.collection('eshtrakat').snapshots();
      _searchEnabled = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  void _showDetailsDialog(
      BuildContext context, QueryDocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${document['name'] ?? 'Unknown'}'),
              Text('Subscription: ${document['subscription'] ?? 'Unknown'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditSubscriptionPage(document: document),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadData() async {
    try {
      final data = await _firestore.collection('eshtrakat').get();
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet.appendRow(['Name', 'Subscription']);

      for (var doc in data.docs) {
        sheet.appendRow([doc['name'] ?? '', doc['subscription'] ?? '']);
      }

      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      final filePath = '${directory.path}/eshtrak_data.xlsx';
      final file = File(filePath);

      final excelData = excel.encode();
      if (excelData != null) {
        await file.writeAsBytes(excelData);
        print('File saved at: $filePath');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data downloaded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to encode Excel data');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download data. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error downloading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'An error occurred while downloading data. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final Stream<QuerySnapshot> eshtrakStream;

  CustomSearchDelegate({required this.eshtrakStream});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: eshtrakStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final List<QueryDocumentSnapshot> data = snapshot.data!.docs;
        final List<QueryDocumentSnapshot> filteredData = data.where((doc) {
          final name = doc['name'].toString().toLowerCase();
          final queryLower = query.toLowerCase();
          return name.contains(queryLower);
        }).toList();

        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            var document = filteredData[index];
            return ListTile(
              title: Text(document['name'] ?? 'No Name'),
              onTap: () {
                close(context, document['name']);
              },
            );
          },
        );
      },
    );
  }
}

class EditSubscriptionPage extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const EditSubscriptionPage({Key? key, required this.document})
      : super(key: key);

  @override
  _EditSubscriptionPageState createState() => _EditSubscriptionPageState();
}

class _EditSubscriptionPageState extends State<EditSubscriptionPage> {
  late TextEditingController _subscriptionController;

  @override
  void initState() {
    super.initState();
    _subscriptionController =
        TextEditingController(text: widget.document['subscription'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subscriptionController,
              decoration: const InputDecoration(labelText: 'Subscription'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('eshtrakat')
                    .doc(widget.document.id)
                    .update({'subscription': _subscriptionController.text});
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EshtrakPage(),
  ));
}
