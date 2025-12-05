import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Center(
        child: SizedBox(
          height: 50,
          width: 70,
          child: Card(
             elevation: 5,
            child: Text("This is Home", style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
        )  ,
    );
  }
}