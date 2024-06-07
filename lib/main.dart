// main.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bara3em/login_page.dart';
import 'package:bara3em/theme_provider.dart';
import 'api_service.dart'; // Import ApiService
import 'welcome_page.dart'; // Update import to match your file structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCV0-NZHjm_0VZRvqEn0WhGc2Kpq49SBa8",
          appId: "1:262757508649:android:9efce8f15c47409ad9de38",
          messagingSenderId: "262757508649",
          projectId: "bara3em-ee851"
      ),
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<ApiService>(create: (_) => ApiService()), // Provide ApiService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade200, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      home: WelcomePage(),
      routes: {
        '/login': (context) => SimpleLoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
