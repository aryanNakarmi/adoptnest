import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  
  final ValueChanged<String> onChanged;
  final String text;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const MyTextfield({super.key,
  required this.onChanged,
  required this.text, 
  required this.hintText, 
  required this.controller,
  this.isPassword = false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,

      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey
      ),
      onChanged: onChanged,
      
    );
  }
}