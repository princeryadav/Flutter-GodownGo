import 'package:flutter/material.dart';
import 'package:namer_app/pages/map_page.dart';
import 'package:namer_app/pages/registration_page.dart' as registration_page;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial screen as RegistrationScreen
      routes: {
        // '/': (context) => const registration_page.RegistrationScreen(), // Registration Screen
        // '/login': (context) => const LoginScreen(),
        '/': (context) => MapScreen(), // Map Screen
      },
    );
  }
}
