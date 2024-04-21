import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanelScreen extends StatelessWidget {
  final bool isAdmin;

  AdminPanelScreen({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    // If the user is not an admin, show a message indicating unauthorized access
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Unauthorized Access'),
        ),
        body: Center(
          child: Text('You are not authorized to access this page.'),
        ),
      );
    }

    // If the user is an admin, show the admin panel
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['displayName']),
                subtitle: Text(data['email']),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Implement delete user functionality
                    _deleteUser(document.id);
                  },
                  child: Text('Delete'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
