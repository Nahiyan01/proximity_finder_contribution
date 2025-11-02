import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proximity_finder/pages/forgot_passoword_page.dart';
import 'package:proximity_finder/pages/home_page.dart';
import 'package:proximity_finder/pages/signup_page.dart';
import 'package:proximity_finder/util/my_button.dart';
import 'package:proximity_finder/util/my_textfield.dart';
import 'package:proximity_finder/util/square_tile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUserIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Icon(Icons.lock, size: 100),
                    const SizedBox(height: 50),
                    Text(
                      'Welcome back! You\'ve been missed!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 25),
                    MyTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 10),
                    MyTextFormField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage()),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyButton(
                      onTap: signUserIn,
                      label: "Sign In",
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SquareTile(icon: Icon(Icons.facebook)),
                        SizedBox(width: 25),
                        SquareTile(icon: Icon(Icons.apple)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Not a member?',
                            style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          ),
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
