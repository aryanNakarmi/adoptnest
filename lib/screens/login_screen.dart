import 'package:adoptnest/screens/signup_screen.dart';
import 'package:adoptnest/widgets/my_button.dart';
import 'package:adoptnest/widgets/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final _formKey= GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
              const SizedBox(height: 50),
              //for title and logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo1.png', height: 50,),
                const Text(
                "AdoptNest",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
                ],
              ),
              
              const SizedBox(height: 40),
              const Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),

              ),
              
              const SizedBox(height: 10),
              Text(
                "Login to your account",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),


//EMAIL
              TextFormField(
              controller: emailController,
              
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: const Icon(Icons.email),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFFFF8C69), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter email";
                if (!value.contains('@')|| !value.contains(".com"))
                return "Enter a valid email";
                return null;
              },
            ),

//PASSWORD
            SizedBox(height: 20,),
             TextFormField(
              controller: passwordController,
              
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFFFF8C69), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Please enter password";
                
                return null;
              },
            ),




//Button
              const SizedBox(height: 30),
              MyButton(
                text: "Login",
                onPressed: () {

                  if(_formKey.currentState!.validate()){
                    setState((){

                    
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    });
                    


                  }

                  // login logic here
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFFFF8C69)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
