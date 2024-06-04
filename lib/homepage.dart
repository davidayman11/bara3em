import 'package:flutter/material.dart';
import 'AdminPanelScreen.dart';
import 'attendance_page.dart';
import 'malyapage.dart';
import 'data_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Bara3emHomePage extends StatefulWidget {
  @override
  _Bara3emHomePageState createState() => _Bara3emHomePageState();
}

class _Bara3emHomePageState extends State<Bara3emHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const AttendancePage(),
    const MalyaPage(username: 'David',),
    const DataPage(),
  ];

  String? getDisplayName() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.displayName;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
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
                getDisplayName() ?? 'User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: null,
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            // Add the new ListTile for the Admin Panel
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanelScreen(isAdmin: true,)),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: signOut,
            ),
          ],
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.lightBlueAccent, // Set the selected item color to blue
        unselectedItemColor: Colors.grey, // Set the unselected item color to grey
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Attendance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Malya',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Data',
          ),
        ],
      ),
    );
  }
}