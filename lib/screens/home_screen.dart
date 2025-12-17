import 'package:adoptnest/screens/bottom_screen/chat_screen.dart';
import 'package:adoptnest/screens/bottom_screen/dashboard_screen.dart';
import 'package:adoptnest/screens/bottom_screen/profile_screen.dart';
import 'package:adoptnest/screens/bottom_screen/rescue_screen.dart';
import 'package:adoptnest/screens/bottom_screen/upload_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const DashboardScreen(),
    const RescueScreen(),
    const UploadScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF8C69),
        child: const Icon(Icons.add_rounded, color: Colors.white,),
        onPressed: (){
          setState(() {
            _selectedIndex =2; //upload screen
          });
        },
        shape: const CircleBorder(),

        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //Home
                IconButton(
                  onPressed: (){
                    setState(() {
                      _selectedIndex = 0;
                    });
                  }, icon: Icon(
                    Icons.home_rounded,
                    color: _selectedIndex == 0? Color(0xFFFF8C69): Colors.grey
                  )
                  ),
                  //Rescue
                  IconButton(onPressed: (){
                  setState(() {
                    _selectedIndex =1;
                  });
                  },
                   icon: Icon(Icons.healing_sharp,
                   color: _selectedIndex == 1? Color(0xFFFF8C69): Colors.grey)
                   ),
                   const SizedBox(width: 48),
                    //chat
                    IconButton(onPressed: (){
                  setState(() {
                    _selectedIndex =3;
                  });
                  },
                   icon: Icon(Icons.chat_rounded,
                   color: _selectedIndex ==3? Color(0xFFFF8C69): Colors.grey)
                   ),
                   //profile
                    IconButton(onPressed: (){
                  setState(() {
                    _selectedIndex =4;
                  });
                  },
                   icon: Icon(Icons.person_rounded,
                   color: _selectedIndex == 4? Color(0xFFFF8C69): Colors.grey)
                   ),
              ],
            ) ,
          ),
        ),
    );
  }
}
