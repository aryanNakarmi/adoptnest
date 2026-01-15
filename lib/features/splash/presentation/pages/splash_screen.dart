import 'dart:async';
import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/core/services/storage/user_session_service.dart';
import 'package:adoptnest/features/home/presentation/pages/home_screen.dart';
import 'package:adoptnest/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  //for splash screen time out
  @override
  void initState(){
    super.initState();
    _navigateToNext();
  }

    Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check if user is already logged in
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate to Dashboard if user is logged in
      AppRoutes.pushReplacement(context, const HomeScreen());
    } else {
      // Navigate to Onboarding if user is not logged in
      AppRoutes.pushReplacement(context, const OnboardingScreen());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
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
      );
  }
}