import 'package:adoptnest/features/screens/login_screen.dart';
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
            onPageChanged: (index) {
              setState(() {
                currentPage = index; //to keep track of the page
              });
            },

            children: [
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
          ),

          //skip button
        if(currentPage!=2)
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
                    activeDotColor: currentPage == 2 ? const Color(0xFF13ECC8) // Get Started
                     : const Color(0xFFFF8C69),
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, //80% of the display
                  child: ElevatedButton(
                  
                    onPressed: (){
                      //when page 3 --> go to login 
                      //or else slide next page
                      if(currentPage==2){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context)=> LoginScreen())
                        );
                      }else{
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500), curve: Curves.easeInOutExpo
                          );
                      }
                    },
                        style:ElevatedButton.styleFrom(
                  
                        backgroundColor: currentPage ==2? const Color(0xFF13ECC8) // Get Started
                       : const Color(0xFFFF8C69), 
                       //Next
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        
                      ),

                    child: Text(currentPage == 2 ? "Get Started": "Next" ,style: TextStyle(fontSize: 18, color: Colors.white),),
                    ),
                )),
            )
            

          
        ],
      )
        
      
    );
  }
}