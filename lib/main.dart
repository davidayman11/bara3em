import 'package:bara3em/welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Fix constructor issue

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.light(), // Use ColorScheme.light() or ColorScheme.dark()
        useMaterial3: true,
      ),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
