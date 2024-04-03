
import 'package:flutter/material.dart';
import 'attendance_page.dart';
import 'malyapage.dart';
import 'data_page.dart';

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
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // New
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

