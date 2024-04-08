// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError || snapshot.data == null) {
              return Center(child: Text('Error: Unable to fetch user data'));
            } else {
              final User user = snapshot.data!;
              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // User profile image
                    CircleAvatar(
                      radius: 80,
                      // Placeholder image
                      backgroundImage: AssetImage('img/5.jpg'),
                    ),
                    SizedBox(height: 20),
                    // User name
                    Text(
                      user.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Divider for separation
                    Divider(),
                    // User details
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(
                        user.email ?? 'No email',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
