import 'dart:async';
import 'package:adoptnest/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //for splash screen time out
  @override
  void initState(){
    super.initState();

    Timer(Duration(seconds: 3),
    (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OnboardingScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}