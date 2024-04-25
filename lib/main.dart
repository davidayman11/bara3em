import 'dart:io';
import 'package:bara3em/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:bara3em/login_page.dart'; // Import your LoginPage widget
import 'theme_provider.dart'; // Import your ThemeProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCV0-NZHjm_0VZRvqEn0WhGc2Kpq49SBa8",
            appId: "1:262757508649:android:9efce8f15c47409ad9de38",
            messagingSenderId: "262757508649",
            projectId: "bara3em-ee851"));
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Create an instance of ThemeProvider
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
      themeMode:
          themeProvider.themeMode, // Use ThemeMode from the ThemeProvider
      home: WelcomePage(),
      routes: {
        '/login': (context) => SimpleLoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
