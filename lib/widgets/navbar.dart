import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:garagem_app/main.dart';
import 'package:garagem_app/widgets/round_rect.dart';
import 'package:garagem_app/navigation_helper.dart';

class Navbar extends StatefulWidget{
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar>{
  int _selectedIndex = -1;
  
  List<IconButton> _createIconButtons(BottomNavigationBarThemeData bottomNavTheme){
    List<IconButton> iconButtons = <IconButton>[];
    for (int i = 0; i < NavigationHelper.routes.length; i++) {
      iconButtons.add(
        IconButton(
          color: (_selectedIndex == i) ? bottomNavTheme.selectedItemColor : bottomNavTheme.unselectedItemColor,
          icon: Container(
            decoration: BoxDecoration(
              boxShadow: (_selectedIndex == i) ? [BoxShadow(color: AllCores.laranja(180), blurRadius: 7, spreadRadius: -2)] : []
            ),
            child: NavigationHelper.icons[i]
          ),
          onPressed: () => _onItemTapped(i),
        )
      );
    }
    return iconButtons;
  }

  void _onItemTapped(int index){
    final routes = NavigationHelper.routes;
    final routeGOTO = routes[index];
    final actualRoute = _getActualRoute();
    if((actualRoute != routeGOTO) && !(routeGOTO == "/home" && actualRoute == "/")) Navigator.pushNamed(context, routeGOTO);
    
    _checkWidgetRoute();
  }

  // Color.fromARGB(255, 255, 94, 0)
  void _checkWidgetRoute(){
    final routes = NavigationHelper.routes;
    final actualRoute = _getActualRoute();
    for(int i = 0; i < routes.length; i++){
      if((routes[i] == actualRoute) || (routes[i] == "/home" && actualRoute == "/")){
        debugPrint("ROUTE: $routes[i] / ACTUAL: $actualRoute");
        setState(() { _selectedIndex = i; });
        break;
      }
    }
  }

  String _getActualRoute() {
    return ModalRoute.of(context)?.settings.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    _checkWidgetRoute();
    BottomNavigationBarThemeData bottomNavTheme = Theme.of(context).bottomNavigationBarTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(GlobalVars.gap * 1.5, 0, GlobalVars.gap * 1.5, GlobalVars.gap * 1.5),
      decoration: BoxDecoration(
        color: AllCores.background(180),
        borderRadius: const BorderRadius.all(Radius.circular(12))
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 2.0,
            sigmaY: 2.0,
          ),
          child: RoundRect(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            color: bottomNavTheme.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _createIconButtons(bottomNavTheme),
            )
          )
        )
      )
    );
  }
}