import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  const OnboardingPage({super.key,
  required this.title,
  required this.subtitle,
  required this.image
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(30),
      child: Column(
        children: [
          Image.asset(image,height: 40,),
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
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
          )

          
        ],
      ),
    );
  }
}