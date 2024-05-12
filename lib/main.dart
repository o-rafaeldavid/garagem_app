import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garagem_app/pages/landing.dart';
import 'package:garagem_app/pages/qr_code.dart';

abstract class NavigationHelper{
  static final List<String> routes = [
    '/'
    '/qr',
  ];

  static final List<Widget> widgets = [
    const LandingScreen(),
    const QRCodeWidget(),
  ];

  static final List<Icon> icons = [
    const Icon(Icons.dashboard_rounded),
    const Icon(Icons.qr_code)
  ];

  static Map<String, WidgetBuilder> createRouteMap(BuildContext context) {
    Map<String, WidgetBuilder> routeMap = {};
    for (int i = 0; i < routes.length; i++) {
      routeMap[routes[i]] = (BuildContext context) => widgets[i];
    }
    return routeMap;
  }
}

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
      routes: NavigationHelper.createRouteMap(context),
    );
  }
}