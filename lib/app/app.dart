import 'package:adoptnest/features/splash/presentation/pages/splash_screen.dart';
import 'package:adoptnest/app/themes/theme_data.dart';
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