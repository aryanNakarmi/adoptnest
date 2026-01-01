import 'package:adoptnest/app/routes/app_routes.dart';
import 'package:adoptnest/core/utils/snackbar_utils.dart';
import 'package:adoptnest/features/auth/presentation/state/auth_state.dart';
import 'package:adoptnest/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:adoptnest/features/screens/bottom_screen/dashboard_screen.dart';
import 'package:adoptnest/features/screens/home_screen.dart';
import 'package:adoptnest/features/auth/presentation/pages/signup_screen.dart';
import 'package:adoptnest/features/auth/presentation/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

   Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
     await ref.
     read(authViewModelProvider.notifier).login(email: _emailController.text.trim(), password: _passwordController.text.trim());
  }
  }
   void _navigateToSignup() {
    AppRoutes.push(context, SignupScreen());
  }

  @override
  Widget build(BuildContext context) {

    final authState = ref.watch(authViewModelProvider);
    ref.listen<AuthState>(authViewModelProvider,(previous, next){
    if(next.status == AuthStatus.authenticated){
        //dashboard
      AppRoutes.pushReplacement(context, DashboardScreen());
    }else if (next.status == AuthStatus.error && next.errorMessage != null){
        //error message
        SnackbarUtils.showError(context, next.errorMessage!);
    }
  });
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
              controller: _emailController,
              
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
              controller: _passwordController,
              
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                if( value.length < 8) return "Enter correct password";
                return null;
              },
            ),




//Button
              const SizedBox(height: 30),

              MyButton(
                text: "Login",
                isLoading: authState.status == AuthStatus.loading,
                onPressed: () async {

                  if(_formKey.currentState!.validate()){
                    await _handleLogin();

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
                    onPressed: _navigateToSignup,
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
