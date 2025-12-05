import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  
  final ValueChanged<String> onChanged;

  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final Icon? prefixIcon;

  const MyTextfield({super.key,
  required this.onChanged,
  required this.hintText, 
  required this.controller,
  this.isPassword = false,
  this.prefixIcon
  
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,

      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

        border:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color.fromARGB(255, 249, 174, 151)), // Border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color(0xFFFF8C69), width: 2), // Border color when focused
        ),

      ),
      onChanged: onChanged,
      
    );
  }
}