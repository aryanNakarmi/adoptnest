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
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.call),label: 'Rescue'),
        BottomNavigationBarItem(icon: Icon(Icons.add),label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Profile'),
      ],

      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() {
          _selectedIndex = index;
        });
      },
      ),
    );
  }
}