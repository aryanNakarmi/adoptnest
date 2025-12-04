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
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey
      ),
      onChanged: onChanged,
      
    );
  }
}