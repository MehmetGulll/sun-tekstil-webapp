import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String title;
  CustomCheckbox({required this.title});

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: _value,
      onChanged: (bool? value) {
        setState(() {
          _value = value ?? false;
        });
      },
    );
  }
}
