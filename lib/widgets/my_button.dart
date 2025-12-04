import 'dart:ui';

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double widthFactor; // fraction of screen width
  final double height;
  const MyButton({super.key, 
  required this.text, 
  required this.onPressed, 
  this.backgroundColor = const Color(0xFFFF8C69), 
  this.textColor = Colors.white, 
  required this.widthFactor, 
  required this.height});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}