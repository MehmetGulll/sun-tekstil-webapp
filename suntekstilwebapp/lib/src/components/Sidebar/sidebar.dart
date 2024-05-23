import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';
import '../../API/url.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late int currentUserId;
  late int userRolId;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  Future<void> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('currentUserId');
    int? userRoleID = await userRolIdHelper.getUserRolId();
    setState(() {
      currentUserId = userId ?? 6;
      userRolId = userRoleID ?? 7;
    });
    print("xdcurrentUserId: $currentUserId");
    print("xduserRolId: $userRolId");
  }

  Future<void> logout(BuildContext context) async {
    final response = await http.post(Uri.parse(ApiUrls.logout));
    if (response.statusCode == 200) {
      print("Çıkış başarılı");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamed(context, '/');
    } else {
      print("Çıkış işlemi başarısız.. ");
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeader = DrawerHeader(
      decoration: BoxDecoration(
        color: Themes.whiteColor,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Image.network(
          'https://static.jimmykey.com/Images/JMK/jimmy_logo_black_1.png',
        ),
      ),
    );
    final homeTile = ListTile(
      leading: Icon(Icons.home),
      title: Text(
        'Ana Sayfa',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/home') {
          Navigator.pushNamed(context, '/home');
        }
      },
    );

    final QuestionsExpansionTile = ListTile(
      leading: Icon(Icons.question_mark),
      title: Text(
        'Denetim Soruları',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/questions') {
          Navigator.pushNamed(context, '/questions');
        }
      },
    );
    final StoreTile = ListTile(
      leading: Icon(Icons.store),
      title: Text(
        'Mağazalar',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/stores') {
          Navigator.pushNamed(context, '/stores');
        }
      },
    );
    final RegionsTile = ListTile(
      leading: Icon(Icons.map),
      title: Text(
        'Bölgeler',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/regions') {
          Navigator.pushNamed(context, '/regions');
        }
      },
    );
    final UserManagementTile = ExpansionTile(
      leading: Icon(Icons.supervised_user_circle),
      title: Text(
        'Kullanıcı Yönetimi',
        style: TextStyle(color: Themes.whiteColor),
      ),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.password),
          title: Text(
            'Şifre Değiştir',
            style: TextStyle(color: Themes.whiteColor),
          ),
          onTap: () {
            if (ModalRoute.of(context)?.settings.name != '/changePassword') {
              Navigator.pushNamed(context, '/changePassword');
            }
          },
        ),
        if (userRolId == 1 || userRolId == 2) ...{
          ListTile(
            leading: Icon(Icons.verified_user_rounded),
            title: Text(
              'Yetkili Kullanıcılar',
              style: TextStyle(color: Themes.whiteColor),
            ),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/officalUsers') {
                Navigator.pushNamed(context, '/officalUsers');
              }
            },
          ),
        }
      ],
    );
    final ReportsTile = ListTile(
      leading: Icon(Icons.report),
      title: Text(
        'Raporlar',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/reports') {
          Navigator.pushNamed(context, '/reports');
        }
      },
    );

    final MailTile = ListTile(
      leading: Icon(Icons.mail),
      title: Text(
        'Mail Yönetimi',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/mailManagement') {
          Navigator.pushNamed(context, '/mailManagement');
        }
      },
    );

    final InspectionTile = ListTile(
      leading: Icon(Icons.content_paste_search_rounded),
      title: Text(
        'Denetimlerim',
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () {
        Navigator.pop(context);
        if (ModalRoute.of(context)?.settings.name != '/inspectionList') {
          Navigator.pushNamed(context, '/inspectionList');
        }
      },
    );

    final ActionTile = ExpansionTile(
      leading: Icon(Icons.date_range_outlined),
      title: Text(
        'Aksiyonlar',
        style: TextStyle(color: Themes.whiteColor),
      ),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.store_mall_directory_outlined),
          title: Text(
            'Mağaza Müdürü Aksiyonları',
            style: TextStyle(color: Themes.whiteColor),
          ),
          onTap: () {
            Navigator.pop(context);
            if (ModalRoute.of(context)?.settings.name !=
                '/storeManagerActions') {
              Navigator.pushNamed(context, '/storeManagerActions');
            }
          },
        ),
        if (currentUserId == 1 || currentUserId == 2) ...{
          ListTile(
            leading: Icon(Icons.manage_search_rounded),
            title: Text(
              'Aksiyonları Görüntüle',
              style: TextStyle(color: Themes.whiteColor),
            ),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/viewActions') {
                Navigator.pushNamed(context, '/viewActions');
              }
            },
          ),
        },
        ListTile(
          leading: Icon(Icons.content_paste_search_rounded),
          title: Text(
            'Denetmen Aksiyonları',
            style: TextStyle(color: Themes.whiteColor),
          ),
          onTap: () {
            Navigator.pop(context);
            if (ModalRoute.of(context)?.settings.name != '/managerActions') {
              Navigator.pushNamed(context, '/managerActions');
            }
          },
        ),
      ],
    );

    final LogOutTile = ListTile(
      leading: Icon(Icons.logout),
      title: Text(
        "Çıkış Yap",
        style: TextStyle(color: Themes.whiteColor),
      ),
      onTap: () async {
        await logout(context);
      },
    );

    return Drawer(
      child: Container(
        color: Themes.blackColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: (userRolId == 1 || userRolId == 2)
              ? [
                  drawerHeader,
                  homeTile,
                  QuestionsExpansionTile,
                  StoreTile,
                  RegionsTile,
                  UserManagementTile,
                  ReportsTile,
                  MailTile,
                  InspectionTile,
                  ActionTile,
                  LogOutTile,
                ]
              : [
                  drawerHeader,
                  homeTile,
                  UserManagementTile,
                  InspectionTile,
                  ActionTile,
                  LogOutTile,
                ],
        ),
      ),
    );
  }
}
