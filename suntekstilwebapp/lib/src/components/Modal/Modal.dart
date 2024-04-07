import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final Color backgroundColor;
  final String text;

  CustomModal({
    required this.backgroundColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(150.0), 
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
