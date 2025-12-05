import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  
  final ValueChanged<String> onChanged;

  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final Icon? prefixIcon;
  final Color borderColor;
  final Color enabledBorderColor;

  const MyTextfield({super.key,
  required this.onChanged,
  required this.hintText, 
  required this.controller,
  this.isPassword = false,

  this.prefixIcon
  

  this.prefixIcon,
  this.borderColor = const Color(0xFFFF8C69),  this.enabledBorderColor= const Color(0xFFFFCBB5),


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

          enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: enabledBorderColor), // Border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: 2), // Border color when focused
        ),

      ),
      onChanged: onChanged,
      
    );
  }
}