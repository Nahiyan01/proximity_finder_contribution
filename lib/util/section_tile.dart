import 'package:flutter/material.dart';

class SectionTile extends StatelessWidget {
  final String icon;
  final String title;
  final bool isEmergency;

  const SectionTile({
    super.key,
    required this.icon,
    required this.title,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          gradient: isEmergency
              ? LinearGradient(colors: [Colors.red[700]!, Colors.red[400]!])
              : LinearGradient(
                  colors: [Colors.blueGrey, Colors.black12, Colors.grey]),
          boxShadow: [
            BoxShadow(
                color:
                    (isEmergency ? Colors.red : Colors.grey).withOpacity(0.3),
                offset: Offset(2, 2),
                blurRadius: 8,
                spreadRadius: 2),
          ],
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isEmergency ? Colors.red[600]! : Colors.blueGrey,
              width: 2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 1),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isEmergency ? FontWeight.bold : FontWeight.normal,
              color: isEmergency ? Colors.white : Colors.black,
            ),
          ),
          if (isEmergency)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'EMERGENCY',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[300],
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
