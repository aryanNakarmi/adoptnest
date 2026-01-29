
import 'package:adoptnest/features/screens/presentation/pages/adopt_screen.dart';
import 'package:adoptnest/features/screens/presentation/pages/chat_screen.dart';
import 'package:adoptnest/features/screens/presentation/pages/dashboard_screen.dart';
import 'package:adoptnest/features/screens/presentation/pages/profile_screen.dart';
import 'package:adoptnest/features/report_animals/presentation/pages/upload_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
 


  @override
  Widget build(BuildContext context) {
      final List<Widget> lstBottomScreen = [
        DashboardScreen(onAdoptTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        }),
        const AdoptScreen(),
        const ReportAnimalScreen(),
        const ChatScreen(),
        const ProfileScreen(),
      ];

    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red, 
        child: const Icon(Icons.add_rounded, color: Colors.white),
        onPressed: () {
          setState(() {
            _selectedIndex = 2; // upload screen
          });
        },
        shape: const CircleBorder(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              icon: Icon(
                Icons.pets_rounded,
                color: _selectedIndex == 0 ? Colors.red : Colors.grey,
              ),
            ),
            // Adopt
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              icon: Icon(
                Icons.healing_sharp,
                color: _selectedIndex == 1 ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(width: 60), // space for FAB
            // Chat
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              icon: Icon(
                Icons.chat_rounded,
                color: _selectedIndex == 3 ? Colors.red : Colors.grey,
              ),
            ),
            // Profile
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 4;
                });
              },
              icon: Icon(
                Icons.person_rounded,
                color: _selectedIndex == 4 ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

