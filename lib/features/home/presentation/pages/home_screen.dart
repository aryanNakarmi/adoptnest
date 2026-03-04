import 'dart:async';
import 'dart:math';
import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/features/adopt/presentation/pages/adopt_screen.dart';
import 'package:adoptnest/features/auth/presentation/pages/login_screen.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:adoptnest/features/chat/presentation/pages/chat_screen.dart';
import 'package:adoptnest/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:adoptnest/features/profile/presentation/pages/profile_screen.dart';
import 'package:adoptnest/features/report_animals/presentation/pages/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // ─── Accelerometer ───────────────────────────────────────────
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  static const double _shakeThreshold = 25.0;
  DateTime? _lastShakeTime;

  // ─── Proximity ───────────────────────────────────────────────
  StreamSubscription<int>? _proximitySubscription;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
    _initProximity();
  }

  void _initAccelerometer() {
    _accelSubscription = userAccelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 1)) {
          _lastShakeTime = now;
          _navigateToReport();
        }
      }
    });
  }

  void _navigateToReport() {
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shake detected! Opening Report screen...'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _initProximity() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      final isNear = event < 4;
      if (isNear && !_dialogShowing) {
        _dialogShowing = true;
        _showLogoutDialog();
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout from AdoptNest?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _dialogShowing = false;
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _dialogShowing = false;
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).then((_) => _dialogShowing = false);
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _proximitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> lstBottomScreen = [
      DashboardScreen(onAdoptTap: () {
        setState(() => _selectedIndex = 1);
      }),
      const AdoptScreen(),
      const ReportAnimalScreen(),
      const SizedBox(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        onPressed: () => setState(() => _selectedIndex = 2),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 0),
              icon: Icon(Icons.pets_rounded,
                  color: _selectedIndex == 0 ? Colors.red : Colors.grey),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              icon: Icon(Icons.healing_sharp,
                  color: _selectedIndex == 1 ? Colors.red : Colors.grey),
            ),
            const SizedBox(width: 60),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
              icon: const Icon(Icons.chat_rounded, color: Colors.grey),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 4),
              icon: Icon(Icons.person_rounded,
                  color: _selectedIndex == 4 ? Colors.red : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}