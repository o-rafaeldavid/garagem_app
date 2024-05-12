import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garagem_app/pages/landing.dart';
import 'package:garagem_app/pages/qr_code.dart';


void main() {
  runApp(const MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estanciunamentu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF111323),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.white,
          onPrimary: Colors.white,
          secondary: Colors.blue,
          onSecondary: Colors.blue,
          error: Colors.white,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.white,
          surface: Colors.white,
          onSurface: Colors.white
        ),
        textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
        headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          // Define more text styles as needed
      ),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
      routes: {
        '/qr': (context) => const QRCodeWidget(),
      },
    );
  }
}