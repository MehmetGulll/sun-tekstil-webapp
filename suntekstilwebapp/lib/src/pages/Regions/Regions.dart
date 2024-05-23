import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';

class Regions extends StatefulWidget {
  @override
  _RegionsState createState() => _RegionsState();
}

class _RegionsState extends State<Regions> {
  String? _chosenRegionState;
  Map<String, String> _regionStateList = {'Aktif': '1', 'Pasif': '0'};
  TextEditingController _searchTextController = TextEditingController();
  List<Map<String, dynamic>> _regions = [];
  final TextEditingController regionNameController = TextEditingController();
  final TextEditingController regionManagerController = TextEditingController();
  final TextEditingController addRegionCodeController = TextEditingController();
  final TextEditingController addRegionNameController = TextEditingController();
  Future<List<dynamic>> getRegions() async {
    try {
      String? token = await TokenHelper.getToken();
      final response = await http.post(
        Uri.parse(ApiUrls.getAllRegion),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
      );
      var data = jsonDecode(response.body);
      var rows = data['allRegion']['rows'];
      var valueCount = rows.length;
      print("Toplam bu kadar değerimiz var :$valueCount");
      return data['allRegion']['rows'];
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  List<Map<String, dynamic>> _region = [];
  Future<int> _getRegionCount() async {
    var url = Uri.parse(ApiUrls.storesUrl);
    var data = await http.get(url);
    var jsonData = json.decode(data.body) as List;
    print(jsonData);

    _region = jsonData.map((item) => item as Map<String, dynamic>).toList();
    int storesCount = _region.length;

    return storesCount;
  }

  Future<void> updateRegion(
      BuildContext context, int id, Map<String, dynamic> region) async {
    try {
      String regionName = regionNameController.text;
      String regionManager = regionManagerController.text;
      String chosenRegionState = _chosenRegionState ?? 'Aktif';
      print("gelen id $id");
      print("Bolge Adı: $regionName");
      print("Bolge Müdürü: $regionManager");
      print("Seçilen bolge durumu : $chosenRegionState");
      String? token = await TokenHelper.getToken();
      final response = await http.post(Uri.parse(ApiUrls.updateRegion),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode(<String, String>{
            "bolge_id": id.toString(),
            "bolge_adi": regionName,
            "status": _regionStateList[chosenRegionState] ?? 'Aktif'
          }));
      if (response.statusCode == 200) {
        print("Başarıyla güncellendi");
        String successMessage = "Güncelleme Başarılı!!";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                successMessage: successMessage,
                successIcon: Icons.check,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/regions');
                },
              );
            });
      } else {
        String errorMessage = "Bir hata oluştu!!";
        print("Hata");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                errorMessage: errorMessage,
                errorIcon: Icons.error,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            });
      }
    } catch (e) {
      print("Hata $e");
    }
  }

  Future<void> addRegion(BuildContext context) async {
    try {
      String? token = await TokenHelper.getToken();
      print(addRegionCodeController);
      print(addRegionNameController);
      final response = await http.post(Uri.parse(ApiUrls.addRegion),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode(<String, String>{
            "bolge_adi": addRegionNameController.text,
            "bolge_kodu": addRegionCodeController.text
          }));
      if (response.statusCode == 201) {
        print("Başarıyla eklendi");
        String successMessage = "Bölge Ekleme Başarılı!!";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                successMessage: successMessage,
                successIcon: Icons.check,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/regions');
                },
              );
            });
      } else if (response.statusCode == 400) {
        String errorMessage = response.body;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                errorMessage: errorMessage,
                errorIcon: Icons.error,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            });
      } else {
        String errorMessage = "Bir hata oluştu!!";
        print("Hata");
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                errorMessage: errorMessage,
                errorIcon: Icons.error,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            });
      }
    } catch (e) {
      print("Hata : $e");
    }
  }

  void showNewRegionModal(
      BuildContext context, Color backgroundColor, String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomModal(
              backgroundColor: backgroundColor,
              text: text,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Yeni Bölge Ekle",
                        style: TextStyle(
                            fontSize: Tokens.fontSize[9],
                            fontWeight: Tokens.fontWeight[6]),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomInput(
                    controller: addRegionCodeController,
                    hintText: 'Bölge Kodu',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomInput(
                    controller: addRegionNameController,
                    hintText: 'Bölge Adı',
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 600),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: "Bölge Ekle",
                              onPressed: () async {
                                print("Onaya basıldı");
                                addRegion(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ]),
                  )
                ],
              ));
        });
  }

  void showModal(
      BuildContext context, Color backgroundColor, String text, Map region) {
    regionManagerController.text = region['bolge_muduru'].toString();
    regionNameController.text = region['bolge_adi'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomModal(
          backgroundColor: backgroundColor,
          text: text,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bölge Düzenle",
                    style: TextStyle(
                        fontSize: Tokens.fontSize[9],
                        fontWeight: Tokens.fontWeight[6]),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: regionNameController,
                hintText: 'Bölge Adı',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Durum",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem: region['status'] == 1 ? 'Aktif' : 'Pasif',
                      items: ['Aktif', 'Pasif'],
                      onChanged: (String? value) {
                        _chosenRegionState = value;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 600),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "Onay",
                      onPressed: () async {
                        print("Onaya basıldı");
                        await updateRegion(context, region['bolge_id'],
                            Map<String, dynamic>.from(region));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Bölgeler',
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: Text(
                "Bölgeler",
                style: TextStyle(
                  fontSize: Tokens.fontSize[9],
                  fontWeight: Tokens.fontWeight[6],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Themes.borderColor,
                  width: 1,
                ),
              ),
            ),
            CustomCard(
              color: Themes.cardBackgroundColor,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                child: CustomButton(
                                    buttonText: "Yeni Bölge Ekle",
                                    onPressed: () {
                                      showNewRegionModal(
                                        context,
                                        Themes.whiteColor,
                                        "",
                                      );
                                    })),
                            FutureBuilder(
                                future: _getRegionCount(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Hata:${snapshot.error}');
                                  } else {
                                    String message = '';
                                    if (snapshot.data != null) {
                                      if (snapshot.data == 0) {
                                        message =
                                            'Herhangi bir bölge bulunamadı';
                                      } else {
                                        message =
                                            'Toplam Bölge Sayısı: ${snapshot.data}';
                                      }
                                    }
                                    return Column(
                                      children: [
                                        Text(
                                          message,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Themes.cardTextColor,
                                              fontSize: Tokens.fontSize[2],
                                              fontWeight: Tokens.fontWeight[8]),
                                        )
                                      ],
                                    );
                                  }
                                })
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: FutureBuilder<List<dynamic>>(
                            future: getRegions(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var region = snapshot.data![index];
                                    return Card(
                                      child: ListTile(
                                        title: Text(region['bolge_adi']),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Bölge Müdürü:"),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  region['bolge_muduru'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          Tokens.fontWeight[6]),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("Durum:"),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  region['status'] == 1
                                                      ? 'Aktif'
                                                      : 'Pasif',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          Tokens.fontWeight[6]),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        trailing: Container(
                                          padding: EdgeInsets.all(8.0),
                                          child: CustomButton(
                                            buttonText: 'Düzenle',
                                            textColor: Themes.blueColor,
                                            buttonColor: Themes.whiteColor,
                                            onPressed: () {
                                              showModal(
                                                  context,
                                                  Themes.whiteColor,
                                                  "",
                                                  region);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Text('Bir hata oluştu');
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
