import 'dart:ui';

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final Color btnColor;
  
  const MyButton({super.key, 
  required this.text, 
  required this.onPressed,  this.btnColor= const Color(0xFFFF8C69), 
 

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width* 0.8,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:  btnColor, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
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