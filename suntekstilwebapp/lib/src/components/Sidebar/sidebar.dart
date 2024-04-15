import 'package:flutter/material.dart';
import '../../constants/theme.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drawerHeader = DrawerHeader(
      decoration: BoxDecoration(
        color: Themes.whiteColor,
      ),
      child: Align(
          alignment: Alignment.center,
          child: Image.network(
              'https://static.jimmykey.com/Images/JMK/jimmy_logo_black_1.png')),
    );
    final homeTile = ListTile(
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
    );

    final settingsTile = ListTile(
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
    );

    final filesExpansionTile = ExpansionTile(
      leading: Icon(Icons.folder),
      title: Text('Dosyalar', style: TextStyle(color: Themes.whiteColor)),
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
    );
    final QuestionsExpansionTile = ListTile(
      leading: Icon(Icons.question_mark),
      title:
          Text('Denetim Soruları', style: TextStyle(color: Themes.whiteColor)),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/questions') {
          Navigator.pushReplacementNamed(context, '/questions');
        }
      },
    );
    final RegionsTile = ListTile(
      leading: Icon(Icons.map),
      title: Text('Bölgeler', style: TextStyle(color: Themes.whiteColor)),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/regions') {
          Navigator.pushReplacementNamed(context, '/regions');
        }
      },
    );
    final UserManagementTile = ExpansionTile(
      leading: Icon(Icons.supervised_user_circle),
      title: Text('Kullanıcı Yönetimi',
          style: TextStyle(color: Themes.whiteColor)),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.password),
          title: Text(
            'Şifre Değiştir',
            style: TextStyle(color: Themes.whiteColor),
          ),
          onTap: () {
            if(ModalRoute.of(context)?.settings.name !='/changePassword'){
              Navigator.pushReplacementNamed(context, '/changePassword');
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.verified_user_rounded),
          title: Text('Yetkili Kullanıcılar',
              style: TextStyle(color: Themes.whiteColor)),
          onTap: () {
            Navigator.pop(context);
            if (ModalRoute.of(context)?.settings.name != '/officalUsers') {
              Navigator.pushReplacementNamed(context, '/officalUsers');
            }
          },
        ),
      ],
    );
      final ReportsTile = ListTile(
      leading: Icon(Icons.report),
      title: Text('Raporlar', style: TextStyle(color: Themes.whiteColor)),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/reports') {
          Navigator.pushReplacementNamed(context, '/reports');
        }
      },
    );

    final LogOutTile = ListTile(
      leading: Icon(Icons.logout),
      title: Text(
        "Çıkış Yap",
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );

    return Drawer(
      child: Container(
        color: Themes.blackColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            drawerHeader,
            homeTile,
            settingsTile,
            filesExpansionTile,
            QuestionsExpansionTile,
            RegionsTile,
            UserManagementTile,
            ReportsTile,
            LogOutTile
          ],
        ),
      ),
    );
  }
}
