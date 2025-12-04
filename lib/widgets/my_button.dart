import 'dart:ui';

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  
  const MyButton({super.key, 
  required this.text, 
  required this.onPressed, 
 

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width* 0.8,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:  const Color(0xFFFF8C69), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
        onPressed: onPressed,
        child: Text(text,style:TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),)
        ),
    );
  }
}