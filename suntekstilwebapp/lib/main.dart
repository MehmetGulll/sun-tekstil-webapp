import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart'; //
import 'package:suntekstilwebapp/src/pages/AddLocation/AddLocation.dart';
import 'package:suntekstilwebapp/src/pages/AddQuestion/AddQuestion.dart';
import 'package:suntekstilwebapp/src/pages/ChangePassword/ChangePassword.dart';
import 'package:suntekstilwebapp/src/pages/HomePage/HomePage.dart';
import 'package:suntekstilwebapp/src/pages/Login/Login.dart';
import 'package:suntekstilwebapp/src/pages/Mail/Mail.dart';
import 'package:suntekstilwebapp/src/pages/OfficalUsers/OfficalUsers.dart';
import 'package:suntekstilwebapp/src/pages/QuestionsPage/QuestionsPage.dart';
import 'package:suntekstilwebapp/src/pages/Register/Register.dart';
import 'package:suntekstilwebapp/src/pages/ReportDetail/ReportDetail.dart';
import 'package:suntekstilwebapp/src/pages/Stores/Stores.dart';
import 'package:suntekstilwebapp/src/pages/Reports/Reports.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProvider(create: (context) => InspectionTypeId()),
      ],
      child: MyApp(),
    ),
  );
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
        '/': (context) => Login(),
        '/home': (context) => Home(),
        '/register': (context) => Register(),
        '/questions': (context) => Questions(),
        '/stores': (context) => Stores(),
        '/addLocation': (context) => AddLocation(),
        '/officalUsers': (context) => OfficalUsers(),
        '/changePassword': (context) => ChangePassword(),
        '/reports': (context) => Reports(),
        '/sendMail': (context) => MailPage(),
        '/addQuestion': (context) => AddQuestion(),
      },
    );
  }
}
