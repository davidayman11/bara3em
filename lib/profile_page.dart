import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // User profile image
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('img/5.jpg'),
            ),
            SizedBox(height: 20),
            // User name
            Text(
              'David Ayman',
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
                'david@example.com',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(
                '011111111111',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
