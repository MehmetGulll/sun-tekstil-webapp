import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/sidebar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String pageTitle;

  const CustomScaffold({
    Key? key, 
    required this.body, 
    this.pageTitle = 'Page Title',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      drawer: Drawer(
        child: Sidebar(),
      ),
      body: body,
    );
  }
}
