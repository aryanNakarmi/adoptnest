import 'package:flutter/material.dart';

class FontData {
  // Headers
  static const TextStyle header1 = TextStyle(
    fontFamily: 'OpenSans Bold',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle header2 = TextStyle(
    fontFamily: 'OpenSans Bold',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontFamily: 'OpenSans Regular',
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'OpenSans Regular',
    fontSize: 14,
    color: Colors.black54,
  );

  // Italic / captions
  static const TextStyle caption = TextStyle(
    fontFamily: 'OpenSans Italic',
    fontSize: 12,
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  );
}
