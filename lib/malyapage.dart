
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'eshtrakat_page.dart';
import 'mo3skr_page.dart';

class MalyaPage extends StatelessWidget {
  final String username;

  const MalyaPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isUserAllowed(username)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Text('You do not have permission to access this page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Malya'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EshtrakPage()),
                );
              },
              child: const Text('Eshtrak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Mo3skrPage()),
                );
              },
              child: const Text('Mo3skr'),
            ),
          ],
        ),
      ),
    );
  }
}
