import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                      return _buildErrorWidget();
                    } else {
                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      return _buildProfileWidget(user, userData);
                    }
                  }
                },
              );
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

  Widget _buildProfileWidget(User user, Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildUserProfileImage(userData['profileImageUrl']), // Pass profile image URL
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
          _buildUserDetails(user.email ?? 'No email'), // Pass user email
        ],
      ),
    );
  }

  Widget _buildUserProfileImage(String? profileImageUrl) {
    return CircleAvatar(
      radius: 80,
      backgroundImage:
           AssetImage('assets/img/5.jpg'), // Fallback to local asset
    );
  }

  Widget _buildUserDetails(String email) {
    return ListTile(
      leading: const Icon(
        Icons.email,
        color: Colors.blueAccent,
      ),
      title: Text(
        email,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

