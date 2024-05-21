import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/sidebar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;

  const CustomScaffold({
    Key? key,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Jimmy Key Denetim Yönetim Sistemi",
            style: 
            TextStyle(color: Colors.black),
          ),
          Image.network(
            'https://static.jimmykey.com/Images/JMK/jimmy_logo_black_1.png',
            fit: BoxFit.fill,
            width: 250,
            height: 50,
          ),
        ],
      )),
      drawer: Drawer(
        child: Sidebar(),
      ),
      body: body,
    );
  }
}
