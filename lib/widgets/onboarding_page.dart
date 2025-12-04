import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  const OnboardingPage({super.key,
  required this.image,
  required this.title,
  required this.subtitle, required MaterialColor ,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsetsGeometry.only(top:170),
            child: 
            Image.asset(image,height:290,),
            ),
            Text(title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text(subtitle,
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            ),
            
        
            
          ],
        ),
      ),
    );
  }
}