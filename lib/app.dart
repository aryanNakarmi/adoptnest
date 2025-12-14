import 'package:adoptnest/screens/splash_screen.dart';
import 'package:adoptnest/themes/theme_widget.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: SplashScreen(),
      
    );
  }
}