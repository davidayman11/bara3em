// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'eshtrakat_page.dart';
import 'mo3skr_page.dart';

class MalyaPage extends StatelessWidget {
  const MalyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Malya Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EshtrakPage()),
                );
              },
              child: Text('Eshtrak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Mo3skrPage()),
                );
              },
              child: Text('Mo3skr'),
            ),
          ],
        ),
      ),
    );
  }
}
