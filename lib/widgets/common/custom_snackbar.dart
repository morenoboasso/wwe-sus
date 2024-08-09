import 'package:flutter/material.dart';

class CustomSnackbar {
  final BuildContext context;
  final String message;
  final IconData icon;

  CustomSnackbar({
    required this.context,
    required this.message,
    required this.icon,
  });

  void show() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        backgroundColor: Colors.red,
        elevation: 1,
      ),
    );
  }
}
