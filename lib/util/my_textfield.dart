import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const MyTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: [AutofillHints.email],
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
