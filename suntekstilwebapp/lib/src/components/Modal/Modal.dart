import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final Widget child;

  CustomModal(
      {required this.backgroundColor, required this.text, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
              child: Column(
            children: [
              Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
              child
            ],
          )),
        ),
      ),
    );
  }
}
