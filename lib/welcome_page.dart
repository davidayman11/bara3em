// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'package:bara3em/homepage.dart';
import 'package:bara3em/login_page.dart';
import 'package:flutter/material.dart';
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds:1), () {
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
