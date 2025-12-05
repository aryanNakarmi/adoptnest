import 'package:adoptnest/widgets/my_button.dart';
import 'package:adoptnest/widgets/my_textfield.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
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
              "Create Your Account",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Join our family and find your new best friend",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            MyTextfield(
              onChanged: (value) {},
              hintText: "Name",
              controller: emailController,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              onChanged: (value) {},
              hintText: "Email",
              controller: emailController,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              onChanged: (value) {},
              hintText: "Password",
              controller: emailController,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 20),
            MyTextfield(
              onChanged: (value) {},
              hintText: "Number",
              controller: passwordController,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 30),
            MyButton(
              text: "Login",
              onPressed: () {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
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
    );
  }
}