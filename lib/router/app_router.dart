import 'package:flutter/material.dart';
import 'package:movam/features/home/home.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.id:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      default:
        throw ("This route name does not exist");
    }
  }
}
