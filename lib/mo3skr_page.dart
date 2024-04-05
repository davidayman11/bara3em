import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}
