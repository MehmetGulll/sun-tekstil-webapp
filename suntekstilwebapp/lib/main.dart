import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/pages/AddLocation/AddLocation.dart';
import 'package:suntekstilwebapp/src/pages/ChangePassword/ChangePassword.dart';
import 'package:suntekstilwebapp/src/pages/HomePage/HomePage.dart';
import 'package:suntekstilwebapp/src/pages/OfficalUsers/OfficalUsers.dart';
import 'package:suntekstilwebapp/src/pages/QuestionsPage/QuestionsPage.dart'; 
import 'package:suntekstilwebapp/src/pages/SettingsPage.dart'; 
import 'package:suntekstilwebapp/src/pages/Regions/Regions.dart';

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
        '/questions': (context) => QuestionsPage(),
        '/regions':(context) => Regions(),
        '/addLocation':(context) => AddLocation(),
        '/officalUsers':(context) => OfficalUsers(),
        '/changePassword':(context) => ChangePassword()
      },
    );
  }
}

