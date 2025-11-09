import 'package:flutter/material.dart';
import '../welcome_screen.dart';
import '../home_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.welcomeScreen:
        return MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        );
      case RouteNames.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('No route defined for \'${settings.name}\'')),
          ),
        );
    }
  }
}
