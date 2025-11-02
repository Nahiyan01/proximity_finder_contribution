import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final Icon icon;

  const SquareTile({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: icon,
    );
  }
}
