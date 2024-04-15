import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    required this.items,
    required this.onChanged,
    this.selectedItem,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _chosenItem;

  @override
  void initState() {
    super.initState();
    _chosenItem = widget.selectedItem;
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(
        color: Colors.grey,
        width: 1.0,
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _chosenItem,
        items: widget.items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _chosenItem = value;
          });
          widget.onChanged(value);
        },
      ),
    ),
  );
}

}

