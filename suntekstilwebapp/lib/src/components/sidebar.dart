import 'package:flutter/material.dart';
import '../constants/theme.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Themes.blackColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Themes.whiteColor,
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Image.network(
                        'https://static.jimmykey.com/Images/JMK/jimmy_logo_black_1.png'))),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'Ana Sayfa',
                style: TextStyle(color: Themes.whiteColor),
              ),
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/') {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Ayarlar',
                style: TextStyle(color: Themes.whiteColor),
              ),
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/settings') {
                  Navigator.pushReplacementNamed(context, '/settings');
                }
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.folder),
              title:
                  Text('Dosyalar', style: TextStyle(color: Themes.whiteColor)),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text(
                    'PDF Dosyaları',
                    style: TextStyle(color: Themes.whiteColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Resim Dosyaları',
                      style: TextStyle(color: Themes.whiteColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
