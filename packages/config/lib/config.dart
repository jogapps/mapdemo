library config;

import 'package:config/environment.dart';
/// A Calculator.
import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final Environment buildFlavor;
  final Widget child;

  AppConfig({required this.child, required this.buildFlavor})
      : super(child: child);

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
