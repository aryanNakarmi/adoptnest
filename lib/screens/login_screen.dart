import 'package:adoptnest/widgets/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100,),
            Text(
              "AdoptNest",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
            ), 
            SizedBox(height: 50,),
            Text(
              "Welcome Back!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10,),
            Text("Login to your account",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
            ),

            SizedBox(height: 20,),
            MyTextfield(
              onChanged: (value){
                //later
              } ,
              hintText: "Email", 
              controller: emailController
              prefixIcon)

          ],
        ),
      )
    );
  }
}