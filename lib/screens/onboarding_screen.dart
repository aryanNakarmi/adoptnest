import 'package:adoptnest/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //horizontal scrollabe page
          PageView(
            children: const [
              OnboardingPage(
                image: 'assets/images/onboarding1.png',
                title: 'Find your new companion', 
                subtitle: 'Find your perfect companion and give them a loving home', 
                
              ),
              OnboardingPage(
                image: 'assets/images/onboarding3.png',
                title: 'Adopt Easily', 
                subtitle: 'Connect with adopters and shelters', 
                
              ),
              OnboardingPage(
                image: 'assets/images/onboarding2.png',
                title: 'Connect. Adopt. Care.', 
                subtitle: 'Find your new bestfriend and give them a forever home', 
                
              )
            ]
              )

            ],
          )
        
      
    );
  }
}