import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/pages/HomePage/HomePage.dart';
import 'package:suntekstilwebapp/src/pages/QuestionsPage/QuestionsPage.dart'; 
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
        '/': (context) => Home(),
        '/settings': (context) => SettingsPage(),
        '/questions': (context) => QuestionsPage()
      },
    );
  }
}

