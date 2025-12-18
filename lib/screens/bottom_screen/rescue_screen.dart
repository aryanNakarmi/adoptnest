import 'package:flutter/material.dart';

class RescueScreen extends StatefulWidget {

  final String mode;
  const RescueScreen({super.key, 
  this.mode = "rescue"
  });

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  
  @override
  Widget build(BuildContext context) {
    final bool isRescue = widget.mode == "rescue";
    return Scaffold(
      appBar: AppBar(
        title:Text(
          isRescue ? "Rescue Animals": "Adopt Animals"
        ),
      ),
      body: Center(
        child: Text(
          isRescue
          ? "Showing animals that need RESCUE"
          : "Showing animals available for ADOPTION"
        ),
      )
    );
  }
}