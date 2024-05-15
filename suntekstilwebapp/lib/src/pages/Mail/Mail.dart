import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
// sağ tarafta iptal edince checkbox yeşil kalması lazımken beyaz oluyor
class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  List<Map<String, dynamic>> _denetimTipleri = [];
  List<Map<String, dynamic>> _tumKullanicilar = [];
  List<Map<String, dynamic>> _selectedUsersLeft = [];
  int _selectedDenetimTipi = 1;
  late TextEditingController _searchTextController;
  Timer? _debounce;

  List<Map<String, dynamic>> _unvanDenetimData = [];
  List<Map<String, dynamic>> _denetimTipineGoreTamObje = [];

  late int denetimTip;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _fetchDenetimTipleri();
    _fetchAllUsers();
    _fetchaAllSelectedKullanici(_selectedDenetimTipi);
    _getAllDataRight(_selectedDenetimTipi);
    denetimTip = _selectedDenetimTipi;
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchDenetimTipleri() async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.get(Uri.parse(ApiUrls.getAllDenetimTipi),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          });

      if (response.statusCode == 200) {
        setState(() {
          _denetimTipleri =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print("Denetim Tipleri: $_denetimTipleri");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.get(Uri.parse(ApiUrls.getAllUsers),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          });

      if (response.statusCode == 200) {
        setState(() {
          _tumKullanicilar =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print("Tüm Kullanıcılar Right: $_tumKullanicilar");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchaAllSelectedKullanici(int denetimTipId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.get(
          Uri.parse(
              '${ApiUrls.getLinkKullaniciDenetimTipiKullanicilari}?denetim_tip_id=$denetimTipId'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          });

      if (response.statusCode == 200) {
        setState(() {
          _selectedUsersLeft =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        print("Tüm Kullanıcılar Left: $_selectedUsersLeft");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _linkKullaniciDenetimTipi(int userId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.post(
          Uri.parse(ApiUrls.linkKullaniciDenetimTipi),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode({
            'kullanici_id': userId,
            'denetim_tip_id': _selectedDenetimTipi,
          }));

      if (response.statusCode == 200) {
        print("Kullanıcı ve denetim tipi bağlantısı başarıyla eklendi.");
        _fetchAllUsers();
        _fetchaAllSelectedKullanici(_selectedDenetimTipi);
      } else {
        throw Exception('Failed to link user and denetim tipi');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteKullaniciDenetimTipiLink(int userId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.post(
          Uri.parse(ApiUrls.deleteKullaniciDenetimTipiLink),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode({
            'kullanici_id': userId,
            'denetim_tip_id': _selectedDenetimTipi,
          }));

      if (response.statusCode == 200) {
        print("Kullanıcı ve denetim tipi bağlantısı başarıyla silindi.");
        _fetchAllUsers();
        _fetchaAllSelectedKullanici(_selectedDenetimTipi);
      } else {
        throw Exception('Failed to delete link between user and denetim tipi');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool isChecked(int userId, int denetimTipId) {
    final selectedUser = _selectedUsersLeft.firstWhere(
      (user) =>
          user['kullanici_id'] == userId &&
          user['denetim_tip_id'] == denetimTipId,
      orElse: () => <String, dynamic>{},
    );
    return selectedUser.isNotEmpty;
  }

  Future<void> _searchUsers(String searchText) async {
    try {
      List<Map<String, dynamic>> filteredUsers = _tumKullanicilar
          .where((user) =>
              user['ad']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              user['soyad']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              user['eposta']
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();

      setState(() {
        _tumKullanicilar = filteredUsers;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _getAllDataRight(int denetimTipId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.get(
        Uri.parse(ApiUrls.getAllUsersByRelatedDenetimTipi),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> unvanDenetimData =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        unvanDenetimData.forEach((data) {
          // set isExpanded property to false in each unvanlar array
          data['unvanlar'].forEach((unvan) {
            unvan['isExpanded'] = false;
          });
        });

        setState(() {
          _unvanDenetimData = unvanDenetimData;
          _denetimTipineGoreTamObje = _unvanDenetimData
              .where(
                (item) => item['denetim_tip_id'] == denetimTipId,
              )
              .toList();
        });
        print("Sağ tüm data: $_unvanDenetimData");
        print(
            "Sağ tüm data: $_denetimTipineGoreTamObje , _selectedDenetimTipi: $_selectedDenetimTipi");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _linkUnvanDenetimTipi(int unvanId, int denetimTipId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.post(Uri.parse(ApiUrls.linkUnvanDenetimTipi),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode({
            'unvan_id': unvanId,
            'denetim_tip_id': denetimTipId,
          }));

      if (response.statusCode == 200) {
        print("Bağlantı başarıyla oluşturuldu. Response: ${response.body}");
      } else {
        throw Exception("Bağlantı oluşturulamadı. Hata: ${response.body}");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteUnvanDenetimTipiLink(
      int unvanId, int denetimTipId) async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.post(
          Uri.parse(ApiUrls.deleteUnvanDenetimTipiLink),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode({
            'unvan_id': unvanId,
            'denetim_tip_id': denetimTipId,
          }));

      if (response.statusCode == 200) {
        print("Bağlantı başarıyla kaldırıldı. Response: ${response.body}");
      } else {
        throw Exception("Bağlantı oluşturulamadı. Hata: ${response.body}");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // future for confirmation dialog for link and delete
  Future<void> _showConfirmationDialog(
      String title, String content, Function onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.pop(context);
              },
              child: Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: DefaultTabController(
        length: _denetimTipleri.length,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    "Mail Yönetimi",
                    style: TextStyle(
                      fontSize: Tokens.fontSize[9],
                      fontWeight: Tokens.fontWeight[6],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: TabBar(
                    isScrollable: true,
                    tabs: _denetimTipleri.map<Widget>((denetimTipi) {
                      return Tab(
                        text: denetimTipi['denetim_tipi'],
                      );
                    }).toList(),
                    onTap: (index) {
                      setState(() {
                        _selectedDenetimTipi =
                            _denetimTipleri[index]['denetim_tip_id'];
                      });
                      _fetchaAllSelectedKullanici(_selectedDenetimTipi);
                      _getAllDataRight(_selectedDenetimTipi);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    //SOL TARAF
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Themes.borderColor,
                            width: 1,
                          ),
                        ),
                        child: CustomCard(
                          color: Themes.cardBackgroundColor,
                          children: [
                            SizedBox(
                              height: 320,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 50,
                                              child: TextField(
                                                controller:
                                                    _searchTextController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Kullanıcı veya E-Posta Adresi Arayın..',
                                                  suffixIcon: IconButton(
                                                    icon: Icon(Icons.search),
                                                    onPressed: () {
                                                      _searchUsers(
                                                          _searchTextController
                                                              .text);
                                                    },
                                                  ),
                                                ),
                                                onChanged: (text) {
                                                  if (_debounce?.isActive ??
                                                      false)
                                                    _debounce!.cancel();
                                                  _debounce = Timer(
                                                      Duration(
                                                          milliseconds: 1000),
                                                      () {
                                                    if (text.isEmpty) {
                                                      _fetchAllUsers();
                                                    } else {
                                                      _searchUsers(text);
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _tumKullanicilar.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final user = _tumKullanicilar[index];
                                          final userId = user['id'];
                                          return Column(
                                            children: [
                                              ListTile(
                                                title: Text(user['ad'] +
                                                    " " +
                                                    user['soyad']),
                                                subtitle: Text(user['eposta']),
                                                leading: Checkbox(
                                                  value: isChecked(userId,
                                                      _selectedDenetimTipi),
                                                  activeColor:
                                                      Themes.greenColor,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      user['selected'] =
                                                          newValue;
                                                      if (newValue == true) {
                                                        _showConfirmationDialog(
                                                          'Seçili Bağlantıyı Onayla',
                                                          'Seçili kullanıcıyı bu denetim tipine bağlamak istediğinizden emin misiniz?',
                                                          () {
                                                            _linkKullaniciDenetimTipi(
                                                                userId);
                                                          },
                                                        );
                                                      } else {
                                                        _showConfirmationDialog(
                                                          'Seçili Bağlantıyı Sil',
                                                          'Seçili kullanıcının bu denetim tipi bağlantısını silmek istediğinizden emin misiniz?',
                                                          () {
                                                            _deleteKullaniciDenetimTipiLink(
                                                                userId);
                                                          },
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    // SAĞ TARAF
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Themes.borderColor,
                            width: 1,
                          ),
                        ),
                        child: CustomCard(
                          color: Themes.cardBackgroundColor,
                          children: [
                            SizedBox(
                              height: 320,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            _denetimTipineGoreTamObje.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final unvanlar =
                                              _denetimTipineGoreTamObje[index]
                                                  ['unvanlar'];
                                          print("Unvanlarssss: $unvanlar");
                                          return Column(
                                            children: [
                                              ListTile(
                                                title: GestureDetector(
                                                  child: Center(
                                                    child: Text(
                                                      _denetimTipineGoreTamObje[
                                                                      index][
                                                                  'denetim_tipi']
                                                              .toString() +
                                                          " Tipi Mail Ayarları",
                                                      style: TextStyle(
                                                        fontSize:
                                                            Tokens.fontSize[4],
                                                        fontWeight: Tokens
                                                            .fontWeight[5],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      unvanlar.forEach((unvan) {
                                                        unvan['isExpanded'] =
                                                            !unvan[
                                                                'isExpanded'];
                                                      });
                                                    });
                                                  },
                                                ),
                                                // subtitle: Text(
                                                //   "Ünvanlar",
                                                //   style: TextStyle(
                                                //     color: Themes.greyColor,
                                                //   ),
                                                // ),
                                              ),
                                              Divider(),
                                              if (unvanlar.isNotEmpty)
                                                ListView.builder(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: unvanlar.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final unvan =
                                                        unvanlar[index];
                                                    return Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              unvan['isExpanded'] =
                                                                  !unvan[
                                                                      'isExpanded'];
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Checkbox(
                                                                  value:
                                                                      unvan['aktif'] ==
                                                                              1
                                                                          ? true
                                                                          : false,
                                                                  activeColor:
                                                                      Themes
                                                                          .greenColor,
                                                                  onChanged: (bool?
                                                                      newValue) {
                                                                    setState(
                                                                        () {
                                                                      unvan['aktif'] =
                                                                          newValue!
                                                                              ? 1
                                                                              : 0;
                                                                      if (newValue ==
                                                                          true) {
                                                                            _showConfirmationDialog(
                                                                              'Seçili Bağlantıyı Onayla',
                                                                              'Seçili unvanı bu denetim tipine bağlamak istediğinizden emin misiniz?',
                                                                              () {
                                                                                _linkUnvanDenetimTipi(
                                                                                    unvan['unvan_id'],
                                                                                    denetimTip);
                                                                              },
                                                                            );
                                                                      } else {
                                                                        _showConfirmationDialog(
                                                                          'Seçili Bağlantıyı Sil',
                                                                          'Seçili unvanın bu denetim tipi bağlantısını silmek istediğinizden emin misiniz?',
                                                                          () {
                                                                            _deleteUnvanDenetimTipiLink(
                                                                                unvan['unvan_id'],
                                                                                denetimTip);
                                                                          },
                                                                        );
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                                Text(
                                                                  unvan[
                                                                      'unvan_adi'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        Tokens.fontSize[
                                                                            3],
                                                                    fontWeight:
                                                                        Tokens.fontWeight[
                                                                            4],
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  unvan['isExpanded']
                                                                      ? Icons
                                                                          .keyboard_arrow_up_rounded
                                                                      : Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (unvan['isExpanded'])
                                                          unvan['kullanicilar']
                                                                  .isEmpty
                                                              ? ListTile(
                                                                  title: Text(
                                                                      "Kullanıcı Bulunamadı",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Themes.accentColor)),
                                                                )
                                                              : ListView
                                                                  .builder(
                                                                  physics:
                                                                      NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: unvan[
                                                                          'kullanicilar']
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final kullanici =
                                                                        unvan['kullanicilar']
                                                                            [
                                                                            index];
                                                                    return ListTile(
                                                                      title:
                                                                          Text(
                                                                        kullanici['ad'] +
                                                                            " " +
                                                                            kullanici['soyad'],
                                                                      ),
                                                                      subtitle: Text(
                                                                          kullanici[
                                                                              'eposta']),
                                                                    );
                                                                  },
                                                                ),
                                                        Divider(),
                                                      ],
                                                    );
                                                  },
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
