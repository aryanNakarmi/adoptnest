import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  //For SplashScreen time out
  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  ))
    })
    ;
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}