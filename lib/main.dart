import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garagem_app/database/database_service.dart';
import 'package:garagem_app/database/garage_status_db.dart';
import 'package:garagem_app/navigation_helper.dart';
import 'package:garagem_app/pages/landing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint("INFORMAÇÃO --- Inicializando base de dados na main");
    final databaseService = DatabaseService();
    /* await databaseService.deleteDB().then( (_) async { */
    await databaseService.initializeDatabase();
    /* }); */
    debugPrint("INFORMAÇÃO --- Inicializada a base de dados com SUCESSO");

    runApp(MyApp());

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  } catch (e) {
    debugPrint('ERRO --- Inicializando a base de dados: $e');
  }
}

///////////
///
abstract class GlobalVars {
  static const double appbarHeight = 148;
  static const double gap = 24;
  static const double iconSize = 32;
}

abstract class AllCores {
  static Color background(int alpha) {
    return Color.fromARGB(alpha, 5, 6, 20);
  }

  static Color laranja(int alpha) {
    return Color.fromARGB(alpha, 250, 90, 26);
  }

  static Color vermelho(int alpha) {
    return Color.fromARGB(alpha, 255, 0, 0);
  }

  static Color verde(int alpha) {
    return Color.fromARGB(alpha, 0, 255, 71);
  }

  static Color amarelo(int alpha) {
    return Color.fromARGB(alpha, 255, 230, 0);
  }

  static Color branco(int alpha) {
    return Color.fromARGB(alpha, 255, 255, 255);
  }
}

abstract class TxtStyles {
  static TextStyle _private(double fontSize, FontWeight fontWeight,
      Color? shadowColor, double radius) {
    return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        shadows: (shadowColor == null)
            ? []
            : [
                BoxShadow(
                  blurRadius: radius,
                  color: shadowColor,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  blurRadius: radius,
                  color: shadowColor,
                  offset: const Offset(0, 0),
                ),
              ]);
  }

  static TextStyle heading1(Color? shadowColor, double radius) {
    return _private(36, FontWeight.w700, shadowColor, radius);
  }

  static TextStyle heading2(Color? shadowColor, double radius) {
    return _private(20, FontWeight.w600, shadowColor, radius);
  }

  static TextStyle paragraph(Color? shadowColor, double radius) {
    return _private(16, FontWeight.w500, shadowColor, radius);
  }

  static TextStyle smallInfo(Color? shadowColor, double radius) {
    return _private(12, FontWeight.w500, shadowColor, radius);
  }
}

///
///////////

class MyApp extends StatelessWidget {
  final GarageStatusDB _garageStatusDB = GarageStatusDB();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _garageStatusDB.getAll().then((data) {
      debugPrint("INFORMAÇÃO --- Todos os dados da base de dados:");
      print(data);

      // para debug | eliminar local table
      /* int length = data.length;
      while(length > 0){
        _garageStatusDB.delete(data[length - 1].id).then((_){
          length = length - 1;
        });
      }
      _garageStatusDB.deleteTable(); */
    }).catchError((e) {
      debugPrint("ERRO --- Ao obter todos os dados da base de dados: $e");
    });

    return MaterialApp(
      title: 'Estanciunamentu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111323)),
        scaffoldBackgroundColor: AllCores.background(255),
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
            onSurface: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
          headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromARGB(20, 255, 255, 255),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white30),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
      routes: NavigationHelper.createRouteMap(context),
    );
  }
}
