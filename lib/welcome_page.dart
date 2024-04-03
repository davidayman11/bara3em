import 'dart:async';
import 'package:flutter/material.dart';
import 'homepage.dart';
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // Start a timer to hide the photo after 2 seconds
    Timer(Duration(seconds:2), () {
      setState(() {
        _isVisible = false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bara3emHomePage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Photo with fade animation
          AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: Duration(seconds: 1),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('img/applogo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // You can add other widgets on top of the photo if needed
        ],
      ),
    );
  }
}
