import 'dart:io';

import 'package:bara3em/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCV0-NZHjm_0VZRvqEn0WhGc2Kpq49SBa8",
            appId: "1:262757508649:android:9efce8f15c47409ad9de38",
            messagingSenderId: "262757508649",
            projectId: "bara3em-ee851"));
    runApp(const MyApp());
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: WelcomePage(),
        debugShowCheckedModeBanner: false
    );
  }
}
