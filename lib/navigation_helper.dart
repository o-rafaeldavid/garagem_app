import 'package:flutter/material.dart';
import 'package:garagem_app/pages/landing.dart';
import 'package:garagem_app/pages/qr_code.dart';

abstract class NavigationHelper{
  static final List<String> routes = [
    '/home',
    '/qr',
    '/settings',
  ];

  static final List<Widget> widgets = [
    const LandingScreen(),
    const QRCodeWidget(),
    const QRCodeWidget(),
  ];

  static final List<Icon> icons = [
    const Icon(Icons.dashboard_rounded),
    const Icon(Icons.qr_code),
    const Icon(Icons.history_rounded),
  ];

  static Map<String, Widget> getRouteMap() {
    Map<String, Widget> routeMap = {};
    for (int i = 0; i < routes.length; i++) {
      routeMap[routes[i]] = widgets[i];
    }
    return routeMap;
  }

  static Map<String, WidgetBuilder> createRouteMap(BuildContext context) {
    Map<String, Widget> routeMap = getRouteMap();
    Map<String, WidgetBuilder> routeMapWidgetBuilder = {};
    routeMap.forEach((route, widget) {
      routeMapWidgetBuilder[route] = (BuildContext context) => widget;
    });
    return routeMapWidgetBuilder;
  }
}