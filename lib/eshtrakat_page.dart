import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EshtrakPage extends StatefulWidget {
  const EshtrakPage({Key? key}) : super(key: key);

  @override
  _EshtrakPageState createState() => _EshtrakPageState();
}

class _EshtrakPageState extends State<EshtrakPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eshtrak Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('eshtrakat').snapshots(),
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
              return ListTile(
                title: Text(document['name'] ?? 'No Name'),
                onTap: () {
                  // Show subscription details and allow editing
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Subscription Details'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Name: ${document['name']}'),
                            Text('Subscription: ${document['subscription']}'),
                            // Add more fields here if needed
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
                              // Navigate to a screen for editing subscription
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
                },
              );
            },
          );
        },
      ),
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
    // Initialize the subscription controller with the current subscription value
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
                // Update the subscription data in Firestore
                FirebaseFirestore.instance
                    .collection('eshtrakat')
                    .doc(widget.document.id)
                    .update({'subscription': _subscriptionController.text});
                // Navigate back to the previous screen
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
