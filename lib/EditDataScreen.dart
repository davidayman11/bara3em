// ignore_for_file: file_names, library_private_types_in_public_api, prefer_final_fields, use_super_parameters

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
        title: const Text('Edit Subscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Name: ${widget.document['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              enabled: false, // Disable editing for the name
              decoration: const InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: widget.document['name'] ?? ''), // Set name text but disable editing
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _subscriptionController,
              decoration: const InputDecoration(labelText: 'Subscription'),
            ),
            const SizedBox(height: 16.0),
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
