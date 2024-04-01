import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late IconData _iconData;

  @override
  void initState() {
    super.initState();
    _updateIconData();
  }

  void _updateIconData() {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _iconData = themeProvider.themeType == ThemeType.Dark ? Icons.dark_mode : Icons.light_mode;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Sidebar Başlık',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context); 
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/settings') {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.folder),
            title: Text('Dosyalar'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('PDF Dosyaları'),
                onTap: () {
                  Navigator.pop(context);
                  // PDF dosyaları sayfasına gitmek için yönlendirme işlemleri
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Resim Dosyaları'),
                onTap: () {
                  Navigator.pop(context);
                  // Resim dosyaları sayfasına gitmek için yönlendirme işlemleri
                },
              ),
            ],
          ),
          ListTile(
            title: Text('Tema Değiştir'),
            trailing: IconButton(
              icon: Icon(_iconData),
              onPressed: () {
                ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                // Tema değişikliği yapılıyor
                if (themeProvider.themeType == ThemeType.System && MediaQuery.of(context).platformBrightness == Brightness.dark) {
                  // Sistem teması karanlıksa ve tema varsayılan olarak sistem temasına ayarlı ise, aydınlık temaya geçiş yap
                  themeProvider.setThemeType(ThemeType.Light);
                } else {
                  // Diğer durumlarda tema değiştirme işlevini uygula
                  themeProvider.setThemeType(
                    themeProvider.themeType == ThemeType.Dark ? ThemeType.Light : ThemeType.Dark,
                  );
                }
                setState(() {
                  _updateIconData(); // Icon data güncelleniyor
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
