import 'package:adoptnest/screens/login_screen.dart';
import 'package:adoptnest/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _controller = PageController();
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //horizontal scrollabe page
          PageView(

            controller: _controller,
            children: const [
              OnboardingPage(
                image: 'assets/images/onboarding1.png',
                title: 'Find your new companion', 
                subtitle: 'Find your perfect companion and give them a loving home',
                bgColor: Colors.green,
                buttonColor: Colors.blue,
                dotColor: Colors.blue,
                skipVisible: true,
                buttonText: "Next"
                
                
              ),
              OnboardingPage(
                image: 'assets/images/onboarding3.png',
                title: 'Adopt Easily', 
                subtitle: 'Connect with adopters and shelters', 
                bgColor: Colors.green,
                buttonColor: Colors.blue,
                dotColor: Colors.blue,
                skipVisible: true,
                buttonText: "Next"
                
                
              ),
              OnboardingPage(
                image: 'assets/images/onboarding2.png',
                title: 'Connect. Adopt. Care.', 
                subtitle: 'Find your new bestfriend and give them a forever home', 
                bgColor: Colors.green,
                buttonColor: Colors.blue,
                dotColor: Colors.blue,
                skipVisible: false,
                buttonText: "Get Started"
                
                
              )
            ]
          ),

          //skip button
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                //to login page
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              child: const Text("Skip"),
            )),

            //dot navigation smoothpage indicator
            Positioned(
              bottom: 170,
              left: 0,
              right: 0,
              child: Center(
                
                child: SmoothPageIndicator(
                  controller: _controller, count: 3,
                  effect: WormEffect(
                    dotHeight: 10,
                    dotWidth: 20,
                    spacing: 8,
                    activeDotColor: Colors.red,
                    dotColor: Colors.grey.shade300,
                  ),
                  ),
              )
              ),
            
            //Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 90,
              child: Center(
                
                child: ElevatedButton(
                  onPressed: (){},
                  child: Icon(Icons.arrow_right, ),
                  )),
            )
            

          
        ],
      )
        
      
    );
  }
}