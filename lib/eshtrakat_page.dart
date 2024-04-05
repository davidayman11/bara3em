import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EshtrakPage extends StatefulWidget {
  const EshtrakPage({Key? key}) : super(key: key);

  @override
  _EshtrakPageState createState() => _EshtrakPageState();
}

class _EshtrakPageState extends State<EshtrakPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _eshtrakStream;
  late TextEditingController _searchController;

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
        title: Text('Eshtrak Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(eshtrakStream: _eshtrakStream),
              );
            },
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
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _eshtrakStream = _firestore.collection('eshtrakat').snapshots();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _eshtrakStream,
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
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(document['name'] ?? 'No Name'),
                        subtitle: Text('Subscription: ${document['subscription'] ?? 'Unknown'}'),
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

  void _showDetailsDialog(BuildContext context, QueryDocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subscription Details'),
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
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSubscriptionPage(document: document),
                  ),
                );
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final Stream<QuerySnapshot> eshtrakStream;

  CustomSearchDelegate({required this.eshtrakStream});

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
      stream: eshtrakStream,
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

class EditSubscriptionPage extends StatefulWidget {
  final QueryDocumentSnapshot document;

  const EditSubscriptionPage({Key? key, required this.document}) : super(key: key);

  @override
  _EditSubscriptionPageState createState() => _EditSubscriptionPageState();
}

class _EditSubscriptionPageState extends State<EditSubscriptionPage> {
  TextEditingController _subscriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subscriptionController.text = widget.document['subscription'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subscriptionController,
              decoration: InputDecoration(labelText: 'Subscription'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('eshtrakat')
                    .doc(widget.document.id)
                    .update({'subscription': _subscriptionController.text});
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
