import 'package:adoptnest/screens/signup_screen.dart';
import 'package:adoptnest/widgets/my_button.dart';
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
      child: Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
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
              controller: emailController,
              prefixIcon: Icon(Icons.email)
              ),

              SizedBox(height: 20,),

               MyTextfield(
              controller: passwordController,
              hintText: "Password",
              isPassword: true,
              prefixIcon: const Icon(Icons.lock),
              onChanged: (value) {
                // later
                },
              ),
              const SizedBox(height: 30),
              

              //Login Button
              MyButton(text: "Login", onPressed: (){
                String email = emailController.text.trim();
                String Password = passwordController.text.trim();

                //later
              }
              ),

              //Signup Page

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context)=>SignupScreen()
                      )
                    );
                  },
                  child: Text("Sign Up", style: TextStyle(color: Color(0xffff8c690)),))
                ],
              )
          ],
        ), 
      )
         )
         )
    );
  }
}