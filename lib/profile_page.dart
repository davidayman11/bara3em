import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
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
    return const Center(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildUserProfileImage(), // Extracted method for user profile image
          const SizedBox(height: 20),
          Text(
            user.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
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
    return const CircleAvatar(
      radius: 80,
      backgroundImage: AssetImage('img/5.jpg'), // Change to your image asset
    );
  }

  Widget _buildUserDetails(User user) {
    return ListTile(
      leading: const Icon(
        Icons.email,
        color: Colors.blueAccent,
      ),
      title: Text(
        user.email ?? 'No email',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
