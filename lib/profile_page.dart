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
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError || snapshot.data == null) {
              return _buildErrorWidget();
            } else {
              final User user = snapshot.data!;
              return _buildProfileWidget(user);
            }
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        'Error: Unable to fetch user data',
        style: TextStyle(
          color: Colors.red,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildProfileWidget(User user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          _buildUserProfileImage(), // Extracted method for user profile image
          SizedBox(height: 20),
          Text(
            user.displayName ?? 'User',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Divider(
            color: Colors.grey[400],
            thickness: 1,
            height: 30,
          ),
          _buildUserDetails(user), // Extracted method for user details
        ],
      ),
    );
  }

  Widget _buildUserProfileImage() {
    return CircleAvatar(
      radius: 80,
      backgroundImage: AssetImage('img/5.jpg'), // Change to your image asset
    );
  }

  Widget _buildUserDetails(User user) {
    return ListTile(
      leading: Icon(
        Icons.email,
        color: Colors.blueAccent,
      ),
      title: Text(
        user.email ?? 'No email',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
