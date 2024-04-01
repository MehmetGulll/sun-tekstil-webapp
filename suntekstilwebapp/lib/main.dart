import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/pages/HomePage.dart'; 
import 'package:suntekstilwebapp/src/pages/SettingsPage.dart'; 
import 'package:suntekstilwebapp/src/theme/theme_provider.dart'; 
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(), // ThemeProvider örneği oluşturun
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Flutter Sidebar Örneği',
            theme: themeProvider.getThemeData(context),
            darkTheme: themeProvider.getThemeData(context).copyWith( 
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.system,
            initialRoute: '/',
            routes: {
              '/': (context) => HomePage(),
              '/settings': (context) => SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
