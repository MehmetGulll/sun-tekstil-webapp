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

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  // SOL TARAF ARRAYLER
  List<Map<String, dynamic>> _denetimTipleri = [];
  List<Map<String, dynamic>> _tumKullanicilar = [];
  List<Map<String, dynamic>> _selectedUsersLeft = [];
  String? _selectedDenetimTipi = '1';
  late TextEditingController _searchTextController;
  Timer? _debounce;

// SAĞ TARAF ARRAYLER
  List<Map<String, dynamic>> _unvanDenetimData = [];

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _fetchDenetimTipleri();
    _fetchAllUsers();
    _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
    _getAllDataRight();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

// SOL TARAF KULLANICILARIN DENETİM TİPİNE GÖRE LİNKLENMESİ
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
        print("Tüm Kullanıcılar1: $_tumKullanicilar");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchaAllSelectedKullanici(String denetimTipId) async {
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
        print("Tüm Kullanıcılar2: $_selectedUsersLeft");
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
        print("Selected Denetim Tipi: $_selectedDenetimTipi");
        _fetchAllUsers();
        _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
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
        _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
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

// SAĞ TARAF UNVAN + DENETİM TİPİNE GÖRE KULLANICILARIN LİNKLENMESİ
  Future<void> _getAllDataRight() async {
    try {
      var token = await TokenHelper.getToken();
      var response = await http.get(
          Uri.parse(ApiUrls.getAllUsersByRelatedDenetimTipi),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          });

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> unvanDenetimData =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        unvanDenetimData.forEach((data) {
          data['isExpanded'] = false;
          data['unvan'].forEach((unvanData) {
            if (unvanData['denetim_tip_id'] == int.parse(_selectedDenetimTipi!)) {
              unvanData['kullanici'] = _tumKullanicilar.firstWhere(
                (user) => user['id'] == unvanData['kullanici_id'],
                orElse: () => <String, dynamic>{},
              );
            }
          });
        }); 
        setState(() {
          _unvanDenetimData = unvanDenetimData;
        });
        print("Unvana göre tüm data: $_unvanDenetimData");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Selected Denetim Tipi: $_selectedDenetimTipi");
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
                            _denetimTipleri[index]['denetim_tip_id'].toString();
                      });
                      _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        // Left section
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
                                                  value: isChecked(
                                                      userId,
                                                      int.parse(
                                                          _selectedDenetimTipi!)),
                                                  activeColor:
                                                      Themes.greenColor,
                                                  onChanged: (bool? newValue) {
                                                    setState(() {
                                                      user['selected'] =
                                                          newValue;
                                                      if (newValue == true) {
                                                        _linkKullaniciDenetimTipi(
                                                            userId);
                                                      } else {
                                                        _deleteKullaniciDenetimTipiLink(
                                                            userId);
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      width: double.infinity,
                                      child: ExpansionPanelList(
                                        expansionCallback:
                                            (int index, bool isExpanded) {
                                          setState(() {
                                            _unvanDenetimData[index]
                                                ['isExpanded'] = !isExpanded;
                                          });
                                        },
                                        children: _unvanDenetimData
                                            .map<ExpansionPanel>((data) {
                                              print("dataaaaaaa.unvan.map ${data['unvan']}");
                                              // each unvan_adi in unvan array  
                                              // DATA İÇERİSİNDEKİ UNVANLARI MAPLE VE İÇERİSİNDEKİ UNVAN_ADİ'Nİ AL 
                                          return ExpansionPanel(
                                            headerBuilder:
                                                (BuildContext context,
                                                    bool isExpanded) {
                                              return ListTile(
                                                title:
                                                    Text(data['denetim_tipi']),
                                              );
                                            },
                                            body: ListTile(
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: data['unvan']
                                                    .map<Widget>(
                                                        (unvanData) => Text(
                                                              '${unvanData['unvan_adi']}: ${unvanData['kullanici'] != null ? '${unvanData['kullanici']['ad']} ${unvanData['kullanici']['soyad']} (${unvanData['kullanici']['eposta']})' : 'Kullanıcı bulunamadı'}',
                                                            ))
                                                    .toList(),
                                              ),
                                            ),
                                            isExpanded: data['isExpanded'],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    print("Mail Ayarları Kaydedildi");
                  },
                  child: Text(
                    'Mail Ayarlarını Kaydet',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
