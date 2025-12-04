import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  PageController _pageController = PageController();
  int currentPage = 0;
  final List<Map<String, String>>onboardingInfo =[
    {
      "title": "Welcome to AdoptNest",
      "subtitle": "Where every stray finds a nest",
      "image":"assets/images/onboarding3.png"
    },
    
    {
      "title": "Adopt your new best friend",
      "subtitle": "Find your perfect companion and give a home to a pet in need.",
      "image":"assets/images/onboarding1.png"
    },
    
    {
      "title": "Connect. Adopt. Care",
      "subtitle": "Our app connects you with a furry buddy to provide them a forever home",
      "image":"assets/images/onboarding2.png"
    },
    
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}