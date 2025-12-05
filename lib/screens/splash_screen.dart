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
    return Scaffold(
      body: Container(
        
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo1.png', height:120,width: 120,),
              SizedBox(height: 20,),
              Text("AdoptNest",
              style: TextStyle(
                  fontWeight: FontWeight.bold,)),
            ],
          ),
        )
      ),
    );
  }
}