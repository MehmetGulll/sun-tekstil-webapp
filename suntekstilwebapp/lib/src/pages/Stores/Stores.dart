import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';

class Stores extends StatefulWidget {
  @override
  _StoresState createState() => _StoresState();
}

Widget buildColumn(BuildContext context, String label, List<String> items,
    ValueChanged<String?> onChanged) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Tokens.fontSize[4]),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: CustomDropdown(
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _StoresState extends State<Stores> {
  TextEditingController storeCodeController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController storeTypeController = TextEditingController();
  TextEditingController storeCityController = TextEditingController();
  TextEditingController storePhoneController = TextEditingController();
  TextEditingController filteredStoreNameController = TextEditingController();
  TextEditingController filteredStoreCityController = TextEditingController();
  bool isFiltered = false;
  String? _chosenStoreType;
  String? _chosenStoreState;
  Map<String, String> _storeTypeList = {'AVM': '1', 'CADDE': '2'};
  Map<String, String> _storeStateList = {'Aktif': '1', 'Pasif': '0'};
  Map<String, String?> selectedValues = {
    'storeCode': '',
    'storeName': '',
    'storeType': '',
    'city': '',
    'storePhone': '',
  };
  List<Map<String, dynamic>> _stores = [];
  Future<List<Map<String, dynamic>>> _getStores() async {
    if (!isFiltered) {
      var url = Uri.parse(ApiUrls.storesUrl);
      var data = await http.get(url);
      var jsonData = json.decode(data.body) as List;
      print(jsonData);

      _stores = jsonData.map((item) => item as Map<String, dynamic>).toList();
    }

    return _stores;
  }

  Future<void> deleteStore(int id) async {
    print(id);
    final response = await http.delete(Uri.parse('${ApiUrls.deleteStore}/$id'));
    if (response.statusCode == 200) {
      print("Mağaza başarıyla silindi");
      setState(() {
        _stores.removeWhere((store) => store['id'] == id);
      });
    } else {
      print("Bir hata oluştu");
    }
  }

  Future<void> updateStore(
      BuildContext context, int id, Map<String, dynamic> store) async {
    try {
      String storeCode = storeCodeController.text;
      String storeName = storeNameController.text;
      String storeType = _chosenStoreType ?? 'AVM';
      String storeCity = storeCityController.text;
      String storeStatus = _chosenStoreState ?? 'Aktif';
      print(id);
      print("status no");
      print(store['status']);
      String? token = await TokenHelper.getToken();
      final response = await http.put(
        Uri.parse('${ApiUrls.updateStore}/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
        body: jsonEncode(<String, String>{
          'storeId': id.toString(),
          'storeCode': storeCodeController.text,
          'storeName': storeNameController.text,
          'storeType': _storeTypeList[storeType] ?? 'AVM',
          'city': storeCityController.text,
          'storePhone': storePhoneController.text,
          'status': _storeStateList[storeStatus] ?? 'Aktif'
        }),
      );

      if (response.statusCode == 200) {
        print("Mağaza başarıyla güncellendi");

        String successMessage = "Güncelleme Başarılı!!";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                successMessage: successMessage,
                successIcon: Icons.check,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/stores');
                },
              );
            });
      //   setState(() {
      //     var updatedStores =
      //         _stores.firstWhere((q) => q['storesId'] == store['storesId']);
      //     updatedStores['status'] = _storeStateList;
      //   });
      // } else {
        print("Bir hata oluştu");
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
      print('Bir hata oluştu: $e');
    }
  }

  Future<void> filteredStore(
      String? queryName, String? queryType, String? queryCity) async {
    print(queryName);
    print(queryType);
    print(queryCity);
    try {
      final response = await http.get(Uri.parse(
          '${ApiUrls.filteredStore}?magaza_adi=${queryName ?? ''}&magaza_tipi=${queryType ?? ''}&sehir=${queryCity ?? ''}'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body) as List;
        setState(() {
          _stores.clear();

          _stores =
              jsonData.map((item) => item as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print("hata: $e");
    }
  }

  List<String> buildDropdownMenuItems(
      List<Map<String, dynamic>>? stores, String key) {
    List<String> items = [];
    if (stores != null) {
      for (var store in stores) {
        var value = store[key];
        if (value is int) {
          value = value.toString();
        }
        items.add(value);
      }
    }
    return items;
  }

  List<Map<String, dynamic>> filterStores(List<Map<String, dynamic>> stores) {
    return stores.where((store) {
      for (var entry in selectedValues.entries) {
        if (entry.value != '' && store[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void showModal(
      BuildContext context, Color backgroundColor, String text, Map store) {
    storeCodeController.text = store['storeCode'].toString();
    storeNameController.text = store['storeName'];
    storeTypeController.text = store['storeType'].toString();
    storeCityController.text = store['city'];
    storePhoneController.text = store['storePhone'];

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
                    "Mağaza Düzenle",
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
                controller: storeCodeController,
                hintText: 'Mağaza Kodu',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: storeNameController,
                hintText: 'Mağaza Adı',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: storeCityController,
                hintText: 'Şehir',
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: storePhoneController,
                hintText: 'Mağaza Telefon',
                keyboardType: TextInputType.text,
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
                      "Mağaza Tipi",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem: store['storeType'] == 1 ? 'AVM' : 'CADDE',
                      items: ['AVM', 'CADDE'],
                      onChanged: (String? value) {
                        _chosenStoreType = value;
                      },
                    ),
                  ],
                ),
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
                      selectedItem: store['status'] == 1 ? 'Aktif' : 'Pasif',
                      items: ['Aktif', 'Pasif'],
                      onChanged: (String? value) {
                        _chosenStoreState = value;
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
                      buttonText: "Düzenle",
                      onPressed: () async {
                        await updateStore(context, store['storeId'],
                            Map<String, dynamic>.from(store));
                        Navigator.of(context).pop();
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "MAĞAZA ADI",
                        style: TextStyle(fontSize: Tokens.fontSize[4]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomInput(
                        controller: filteredStoreNameController,
                        hintText: 'MAĞAZA ADI',
                        keyboardType: TextInputType.name,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  buildColumn(
                      context,
                      "MAĞAZA TİPİ",
                      _storeTypeList.keys.toList(),
                      (value) => setState(() => _chosenStoreType = value)),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "ŞEHİR",
                        style: TextStyle(fontSize: Tokens.fontSize[4]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomInput(
                        controller: filteredStoreCityController,
                        hintText: 'ŞEHİR',
                        keyboardType: TextInputType.name,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        buttonText: "Filtreleme",
                        onPressed: () {
                          String? queryValue = _storeTypeList[_chosenStoreType];
                          isFiltered = true;
                          filteredStore(filteredStoreNameController.text,
                              queryValue, filteredStoreCityController.text);
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomButton(
                        buttonText: "Mağaza Ekle",
                        onPressed: () {
                          Navigator.pushNamed(context, '/addLocation');
                        },
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomButton(
                        buttonText: "Filtreleri Sil",
                        buttonColor: Themes.secondaryColor,
                        onPressed: () async {
                          print("Filtreler kaldırıldı");
                          isFiltered = false;
                          await _getStores();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            FutureBuilder(
              future: _getStores(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var stores = snapshot.data;
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(30),
                        child: Text(
                          "Mağazalar",
                          style: TextStyle(
                              fontSize: Tokens.fontSize[9],
                              fontWeight: Tokens.fontWeight[6]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: FutureBuilder<List>(
                          future: _getStores(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              List<TableRow> rows = snapshot.data!.map((store) {
                                return TableRow(children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['storeCode'],
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['storeName'],
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['storeType'] == 1 ? 'AVM' : 'CADDE',
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['city'],
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['storePhone'],
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      store['status'] == 1 ? 'Aktif' : 'Pasif',
                                      style: TextStyle(
                                          fontWeight: Tokens.fontWeight[2]),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: CustomButton(
                                      buttonText: 'Düzenle',
                                      textColor: Themes.blueColor,
                                      buttonColor: Themes.whiteColor,
                                      onPressed: () {
                                        showModal(context, Themes.whiteColor,
                                            "", store);
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList();
                              return Table(
                                defaultColumnWidth: FlexColumnWidth(1),
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                  4: FlexColumnWidth(1),
                                },
                                border:
                                    TableBorder.all(color: Themes.blackColor),
                                children: [
                                  TableRow(children: [
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "MAĞAZA KODU",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "MAĞAZA ADI",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "MAĞAZA TİPİ",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "ŞEHİR",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "MAĞAZA TELEFON",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "DURUMU",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Themes.yellowColor,
                                      child: Text(
                                        "DÜZENLE",
                                        style: TextStyle(
                                            fontWeight: Tokens.fontWeight[2]),
                                      ),
                                    ),
                                  ]),
                                  ...rows,
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
