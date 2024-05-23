import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/sidebar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? pageTitle;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.pageTitle
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(pageTitle ?? 'Jimmy Key Denetleme Sistemi'),
              Image.network(
                'https://static.jimmykey.com/Images/JMK/jimmy_logo_black_1.png',
                fit: BoxFit.fill,
                width: 250,
                height: 50,
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: Sidebar(),
        ),
        body: body,
      ),
    );
  }
}
