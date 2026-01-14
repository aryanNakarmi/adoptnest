import 'package:flutter/material.dart';

class AdoptScreen extends StatefulWidget {
  const AdoptScreen({super.key});

  @override
  State<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends State<AdoptScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child:Center(
      child: Text("Adopt"),
    ));
  }
}