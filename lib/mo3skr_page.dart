import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mo3skrPage extends StatefulWidget {
  @override
  _Mo3skrPageState createState() => _Mo3skrPageState();
}

class _Mo3skrPageState extends State<Mo3skrPage> {
  late QuerySnapshot _currentSnapshot;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController taly3aController = TextEditingController();
  final TextEditingController paidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mo3skr Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('mo3skr').snapshots(),
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
                  _currentSnapshot = snapshot.data!;
                  return ListView.builder(
                    itemCount: _currentSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      var document = _currentSnapshot.docs[index];
                      return ListTile(
                        title: Text(document['name'] ?? ''),
                        subtitle: Text('Taly3a: ${document['taly3a'] ?? ''}, Paid: ${document['paid'] ?? ''}'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(context, document);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
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
                _clearControllers();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveData();
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
    nameController.text = document['name'];
    taly3aController.text = document['taly3a'];
    paidController.text = document['paid'];

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
                _clearControllers();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateData(document.id);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveData() {
    _firestore.collection('mo3skr').add({
      'name': nameController.text,
      'taly3a': taly3aController.text,
      'paid': paidController.text,
    });
    _clearControllers();
  }

  void _updateData(String docId) {
    _firestore.collection('mo3skr').doc(docId).update({
      'name': nameController.text,
      'taly3a': taly3aController.text,
      'paid': paidController.text,
    });
    _clearControllers();
  }

  void _clearControllers() {
    nameController.clear();
    taly3aController.clear();
    paidController.clear();
  }
}
