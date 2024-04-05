import 'package:flutter/material.dart';
import 'attendance_page.dart';
import 'malyapage.dart';
import 'data_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
                'David Ayman',
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
              onTap: () {
                // Sign out logic goes here
                // You can add your sign out logic, such as clearing user session, navigating to login screen, etc.
              },
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
