import 'package:flutter/material.dart';

class SectionTile extends StatelessWidget {
  final String icon;
  final String title;

  const SectionTile({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.black12, Colors.grey]),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: Offset(2, 2),
                blurRadius: 8,
                spreadRadius: 2),
          ],
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: BoxBorder.all(color: Colors.blueGrey, width: 2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 1),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
