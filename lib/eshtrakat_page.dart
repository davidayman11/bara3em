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
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
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
                    var data = document.data() as Map<String, dynamic>;
                    var name = data['name'] ?? 'No Name';
                    var subscription = data['subscription'] ?? 'Unknown';
                    var notes = data['notes'] ?? 'No Notes';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subscription: $subscription'),
                            Text('Notes: $notes'),
                          ],
                        ),
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

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _eshtrakStream = _firestore.collection('eshtrakat').snapshots();
    });
  }

  void _showDetailsDialog(BuildContext context, DocumentSnapshot document) {
    var data = document.data() as Map<String, dynamic>;
    var name = data['name'] ?? 'No Name';
    var notes = data['notes'] ?? '';
    var subscription = data['subscription'] ?? '';

    var notesController = TextEditingController(text: notes);
    var subscriptionController = TextEditingController(text: subscription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              TextField(
                controller: subscriptionController,
                decoration: InputDecoration(labelText: 'Subscription'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                document.reference.update({
                  'notes': notesController.text,
                  'subscription': subscriptionController.text,
                });

                Navigator.of(context).pop();
              },
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

      sheet.appendRow(['Name', 'Subscription', 'Notes']);

      for (var doc in data.docs) {
        var docData = doc.data() as Map<String, dynamic>;
        sheet.appendRow([
          docData['name'] ?? '',
          docData['subscription'] ?? '',
          docData['notes'] ?? ''
        ]);
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

class EditSubscriptionPage extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const EditSubscriptionPage({Key? key, required this.document})
      : super(key: key);

  @override
  _EditSubscriptionPageState createState() => _EditSubscriptionPageState();
}

class _EditSubscriptionPageState extends State<EditSubscriptionPage> {
  late TextEditingController _subscriptionController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    var data = widget.document.data() as Map<String, dynamic>;
    _subscriptionController = TextEditingController(text: data['subscription']?.toString() ?? '');
    _notesController = TextEditingController(text: data['notes']?.toString() ?? '');
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
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                widget.document.reference.update({
                  'subscription': _subscriptionController.text,
                  'notes': _notesController.text,
                });
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
