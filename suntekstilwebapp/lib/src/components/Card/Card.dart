import 'package:flutter/cupertino.dart';
import '../../constants/tokens.dart';

class CustomCard extends StatelessWidget {
  final Color color;
  final List<Widget> children;

  CustomCard({required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
                Tokens.borderRadius[1]!)),
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: children,
              ),
            )),
      ),
    );
  }
}
