import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/pages/AddLocation/AddLocation.dart';
import 'package:suntekstilwebapp/src/pages/ChangePassword/ChangePassword.dart';
import 'package:suntekstilwebapp/src/pages/HomePage/HomePage.dart';
import 'package:suntekstilwebapp/src/pages/Login/Login.dart';
import 'package:suntekstilwebapp/src/pages/OfficalUsers/OfficalUsers.dart';
import 'package:suntekstilwebapp/src/pages/QuestionsPage/QuestionsPage.dart';
import 'package:suntekstilwebapp/src/pages/Register/Register.dart'; 
import 'package:suntekstilwebapp/src/pages/SettingsPage.dart'; 
import 'package:suntekstilwebapp/src/pages/Regions/Regions.dart';
import 'package:suntekstilwebapp/src/pages/Reports/Reports.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jimmy Key Denetleme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => Login(),
        '/home': (context) => Home(),
        '/stores':(context) => Register(),
        '/settings': (context) => SettingsPage(),
        '/questions': (context) => QuestionsPage(),
        '/regions':(context) => Regions(),
        '/addLocation':(context) => AddLocation(),
        '/officalUsers':(context) => OfficalUsers(),
        '/changePassword':(context)=>ChangePassword(),
        '/reports': (context) => Reports()
        
      },
    );
  }
}

