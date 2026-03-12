import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(GatherPayApp());
}

class GatherPayApp extends StatefulWidget {
  @override
  _GatherPayAppState createState() => _GatherPayAppState();
}

class _GatherPayAppState extends State<GatherPayApp> {

  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GatherPay",

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
      ),

      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: LoginScreen(toggleTheme: toggleTheme),
    );
  }
}