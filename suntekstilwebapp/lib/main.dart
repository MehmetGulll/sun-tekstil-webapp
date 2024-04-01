import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/sidebar.dart'; 
import 'package:suntekstilwebapp/src/pages/HomePage.dart'; 
import 'package:suntekstilwebapp/src/pages/SettingsPage.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sidebar Örneği',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}

