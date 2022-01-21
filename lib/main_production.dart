import 'package:config/config.dart';
import 'package:config/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:movam/app.dart';

void main() {
  var configuredApp = AppConfig(
    buildFlavor: Environment.production,
    child: MyApp(),
  );
  return runApp(configuredApp);
}
