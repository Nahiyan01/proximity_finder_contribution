import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proximity_finder/util/my_button.dart';
import 'package:proximity_finder/util/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset email sent!")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                    const Icon(Icons.lock_reset, size: 100),
                    const SizedBox(height: 50),
                    Text(
                      'Reset Your Password',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 25),
                    MyTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 25),
                    MyButton(
                      onTap: resetPassword,
                      label: "Reset",
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
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
