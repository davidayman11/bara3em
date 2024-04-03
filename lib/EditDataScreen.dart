import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
            Text(
              'Name: ${widget.document['name']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              enabled: false, // Disable editing for the name
              decoration: InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: widget.document['name'] ?? ''), // Set name text but disable editing
            ),
            SizedBox(height: 16.0),
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
