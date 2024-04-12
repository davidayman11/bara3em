// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class Mo3skrPage extends StatefulWidget {
  @override
  _Mo3skrPageState createState() => _Mo3skrPageState();
}

class _Mo3skrPageState extends State<Mo3skrPage> {
  late Stream<QuerySnapshot> _mo3skrStream;
  late TextEditingController _searchController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _mo3skrStream = _firestore.collection('mo3skr').snapshots();
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
        title: Text('Mo3skr'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _downloadData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20), // Adjust padding
                border: OutlineInputBorder( // Defines the border
                  borderRadius: BorderRadius.circular(30.0), // Adjust the corner radius for rounder edges
                ),
                enabledBorder: OutlineInputBorder( // Border style when TextField is enabled
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder( // Border style when TextField is focused
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _mo3skrStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var document = snapshot.data!.docs[index];
                    return InkWell(
                      onTap: () {
                        _showEditDialog(context, document);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Taly3a: ${document['taly3a'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Paid: ${document['paid'] ?? ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController taly3aController = TextEditingController();
    final TextEditingController paidController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: taly3aController,
                decoration: InputDecoration(labelText: 'Taly3a'),
              ),
              TextField(
                controller: paidController,
                decoration: InputDecoration(labelText: 'Paid'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _clearControllers(nameController, taly3aController, paidController);
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveData(nameController.text, taly3aController.text, paidController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(BuildContext context, DocumentSnapshot document) async {
    final TextEditingController nameController = TextEditingController(text: document['name']);
    final TextEditingController taly3aController = TextEditingController(text: document['taly3a']);
    final TextEditingController paidController = TextEditingController(text: document['paid']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: taly3aController,
                decoration: InputDecoration(labelText: 'Taly3a'),
              ),
              TextField(
                controller: paidController,
                decoration: InputDecoration(labelText: 'Paid'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _clearControllers(nameController, taly3aController, paidController);
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateData(document.id, nameController.text, taly3aController.text, paidController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveData(String name, String taly3a, String paid) {
    _firestore.collection('mo3skr').add({
      'name': name,
      'taly3a': taly3a,
      'paid': paid,
    });
  }

  void _updateData(String docId, String name, String taly3a, String paid) {
    _firestore.collection('mo3skr').doc(docId).update({
      'name': name,
      'taly3a': taly3a,
      'paid': paid,
    });
  }

  void _clearControllers(TextEditingController nameController, TextEditingController taly3aController,
      TextEditingController paidController) {
    nameController.clear();
    taly3aController.clear();
    paidController.clear();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _mo3skrStream = _firestore.collection('mo3skr').snapshots();
      } else {
        _mo3skrStream = _firestore
            .collection('mo3skr')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .snapshots();
      }
    });
  }

  Future<void> _downloadData() async {
    try {
      final data = await _firestore.collection('mo3skr').get();
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet.appendRow(['Name', 'Taly3a', 'Paid']);

      for (var doc in data.docs) {
        sheet.appendRow([doc['name'] ?? '', doc['taly3a'] ?? '', doc['paid'] ?? '']);
      }

      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      final filePath = '${directory.path}/mo3skr_data.xlsx';
      final file = File(filePath);

      final excelData = excel.encode();
      if (excelData != null) {
        await file.writeAsBytes(excelData);
        print('File saved at: $filePath');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data downloaded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Failed to encode Excel data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download data. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error downloading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while downloading data. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final Stream<QuerySnapshot> mo3skrStream;

  CustomSearchDelegate({required this.mo3skrStream});

  @override
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
      stream: mo3skrStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
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

void main() {
  runApp(MaterialApp(
    home: Mo3skrPage(),
  ));
}
