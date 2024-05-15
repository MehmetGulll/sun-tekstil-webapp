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
  List<Map<String, dynamic>> _denetimTipleri = [];
  List<Map<String, dynamic>> _tumKullanicilar = [];
  List<Map<String, dynamic>> _selectedUsersLeft = [];
  String? _selectedDenetimTipi = '1';
  late TextEditingController _searchTextController;
  Timer? _debounce;

  List<Map<String, dynamic>> _unvanDenetimData = [];
  List<Map<String, dynamic>> _unvanHeader = [];
  List<Map<String, dynamic>> _selectedDenetimTipiPanelList = [];
  List<Map<String, dynamic>> _selectedDenetimTipiBody = [];

  late int denetimTip;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    _fetchDenetimTipleri();
    _fetchAllUsers();
    _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
    _getAllDataRight(_selectedDenetimTipi!);
    denetimTip = int.tryParse(_selectedDenetimTipi!) ?? 1;
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

  Future<void> _getAllDataRight(String denetimTipId) async {
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
          data['isExpanded'] = false;
        });

        setState(() {
          _unvanDenetimData = unvanDenetimData;
          _unvanHeader = _unvanDenetimData
              .map((item) => {
                    'denetim_tipi': item['denetim_tip_id'],
                    'unvanlar': item['unvanlar'],
                  })
              .toList();

          _selectedDenetimTipiPanelList = _unvanHeader
              .where(
                (item) => item['denetim_tipi'] == int.parse(denetimTipId),
              )
              .toList();
          _selectedDenetimTipiBody = _selectedDenetimTipiPanelList
              .map((item) => {'unvanlar': item['unvanlar']})
              .toList();
        });
        print("_selectedDenetimTipiBodyabc: $_selectedDenetimTipiBody");
        print("Unvan Headerabc: $_unvanHeader , _selectedDenetimTipi: $_selectedDenetimTipi , ");
        print("Sağ tüm data: $_unvanDenetimData");
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
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
                            _denetimTipleri[index]['denetim_tip_id'].toString();
                      });
                      _fetchaAllSelectedKullanici(_selectedDenetimTipi!);
                      _getAllDataRight(_selectedDenetimTipi!);
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
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Ünvana Göre Mail Yönetimi",
                                              style: TextStyle(
                                                fontSize: Tokens.fontSize[4],
                                                fontWeight:
                                                    Tokens.fontWeight[5],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount:
                                            _selectedDenetimTipiBody.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final unvan =
                                              _selectedDenetimTipiBody[index];
                                          // for accordion button full data
                                          // [{unvan_id: 5, unvan_adi: İnsan Kaynakları Grup Müdürü, kullanicilar: []}, {unvan_id: 6, unvan_adi: Süreç iyileştirme Müdürü, kullanicilar: []}, {unvan_id: 7, unvan_adi: Süreç İyileştirme Uzman Yardımcısı, kullanicilar: [{id: 1, ad: Atakan, soyad: Doğan, eposta: atakandogan2001@gmail.com, unvan_id: 7}]}]
                                          final unvanlar = unvan['unvanlar'];

                                          // for accordion button header
                                          // [{İnsan Kaynakları Grup Müdürü}, {Süreç iyileştirme Müdürü}, {Süreç İyileştirme Uzman Yardımcısı}]
                                          final unvan_adi = unvanlar
                                              .map((item) => {
                                                    item['unvan_adi'],
                                                  })
                                              .toList();
                                          // for accordion button  expanded body
                                          // [{[]}, {[]}, {[{id: 1, ad: Atakan, soyad: Doğan, eposta: atakandogan2001@gmail.com, unvan_id: 7}]}]
                                          final kullanicilar = unvanlar
                                              .map((item) => {
                                                    item['kullanicilar'],
                                                  })
                                              .toList();

                                          // print("selectedDenetimTipi $_selectedDenetimTipi  , abcd0: $unvan");
                                          print(
                                              "selectedDenetimTipi $_selectedDenetimTipi  , abcd1: $kullanicilar");
                                          print(
                                              "selectedDenetimTipi $_selectedDenetimTipi  , abcd2: $unvanlar");
                                          print(
                                              "selectedDenetimTipi $_selectedDenetimTipi  , abcd3: $unvan_adi");
                                          return  Column(
                                            children: [
                                              // Expansion panel
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
