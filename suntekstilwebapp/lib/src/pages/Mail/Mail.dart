import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
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
  String? _selectedDenetimTipi;

  @override
  void initState() {
    super.initState();
    _fetchDenetimTipleri();
    _fetchAllUsers();
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
        print("Tüm Kullanıcılar: $_tumKullanicilar");
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
      body: SingleChildScrollView(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 250,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDenetimTipi,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDenetimTipi = newValue;
                        });
                      },
                      items: _denetimTipleri
                          .map<DropdownMenuItem<String>>((denetimTipi) {
                        return DropdownMenuItem<String>(
                          value: denetimTipi['denetim_tip_id'].toString(),
                          child: Text(denetimTipi['denetim_tipi']),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        labelText: 'Denetim Tipi',
                        hintText: 'Denetim Tipi Seçiniz',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
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
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Row(
                                        // ayrıca kullanıcı maili ekleme yeri
                                      ),
                                      Row(
                                        //  tüm kullanıcılar ve mailleri olan alan (listelenecek) tüm kullanıcıların yanında + butonu olacak 
                                      )
                                    ],
                                  ),
                                ),
                              ],
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
                      // Right section
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
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    width: double.infinity,
                                    // child:
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
              CustomButton(
                buttonText: 'Mail Gönder',
                onPressed: () {
                  print("Gönderildi");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
