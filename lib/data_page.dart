import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Stream<QuerySnapshot> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = FirebaseFirestore.instance.collection('bara3em_database').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              // Handle the selected item if needed
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _dataStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Details'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Name: ${document['name'] ?? 'Unknown'}'),
                            Text('Phone: ${document['phone'] ?? 'Unknown'}'),
                            Text('Team: ${document['team'] ?? 'Unknown'}'),
                            // Add more details here as needed
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: ListTile(
                  title: Text(document['name'] ?? 'No Name'),
                  // Add more ListTile properties to display additional data from the document
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class CustomSearchDelegate extends SearchDelegate<String> {
  final Stream<QuerySnapshot> dataStream;

  CustomSearchDelegate(this.dataStream);

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
    return StreamBuilder(
      stream: dataStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
