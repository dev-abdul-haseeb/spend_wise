import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/config/routes/route_names.dart';

import 'package:spend_wise/view/views.dart';

class Routes{
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RouteNames.loginScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case RouteNames.profileScreen:
        return MaterialPageRoute(builder: (context) => ProfileScreen());
      case RouteNames.authNavigator:
        return MaterialPageRoute(builder: (context) => AuthNavigator());

      default:
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
            body: Center(child: Text('No route')),
          );
        });
    }
  }
}