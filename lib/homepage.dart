// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, avoid_print, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'attendance_page.dart';
import 'malyapage.dart';
import 'data_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Bara3emHomePage extends StatefulWidget {
  @override
  _Bara3emHomePageState createState() => _Bara3emHomePageState();
}

class _Bara3emHomePageState extends State<Bara3emHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    AttendancePage(),
    MalyaPage(),
    DataPage(),
  ];

  // Function to retrieve user's display name
  String? getDisplayName() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.displayName;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Function to sign out
  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to login page or any other page after sign out
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                getDisplayName() ?? 'User', // Use user's display name if available, else fallback to 'User'
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: null, // No email displayed
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: signOut, // Call signOut function here
            ),
          ],
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Malya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Data',
          ),
        ],
      ),
    );
  }
}
