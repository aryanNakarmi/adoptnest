import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    fontFamily: 'DMSans Regular',
    useMaterial3: true,


      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFF8C69),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'DMSans Regular',
        ),
      ),
    ),

  );
}