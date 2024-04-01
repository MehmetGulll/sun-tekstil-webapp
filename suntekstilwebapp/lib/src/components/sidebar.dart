import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
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
              Navigator.pushNamed(context, '/'); 
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ayarlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
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
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Resim Dosyaları'),
                onTap: () {
                  Navigator.pop(context); 
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
