import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
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

Widget buildRow(
    String label, List<String> items, ValueChanged<String?> onChanged) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(label),
            flex: 1,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomDropdown(
                items: items,
                onChanged: onChanged,
              ),
              flex: 2)
        ],
      ));
}

class _StoresState extends State<Stores> {
  TextEditingController storeCodeController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();
  TextEditingController storeTypeController = TextEditingController();
  TextEditingController storeCityController = TextEditingController();
  TextEditingController storePhoneController = TextEditingController();
  Map<String, String?> selectedValues = {
    'storeCode': '',
    'storeName': '',
    'storeType': '',
    'city': '',
    'storePhone': '',
  };
  List<Map<String, dynamic>> _stores = [];
  Future<List<Map<String, dynamic>>> _getStores() async {
    var url = Uri.parse(ApiUrls.storesUrl);
    var data = await http.get(url);
    var jsonData = json.decode(data.body) as List;
    print(jsonData);

    _stores = jsonData.map((item) => item as Map<String, dynamic>).toList();

    return jsonData.map((item) => item as Map<String, dynamic>).toList();
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
      var currentStatus = store['status'];
      var newStatus = currentStatus == 0 ? 1 : 0;
      store['status'] = newStatus;
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
          'storeType': storeTypeController.text,
          'city': storeCityController.text,
          'storePhone': storePhoneController.text,
          'status': newStatus.toString()
        }),
      );

      if (response.statusCode == 200) {
        print("Mağaza başarıyla güncellendi");
        setState(() {
          var updatedStores =
              _stores.firstWhere((q) => q['storesId'] == store['storesId']);
          updatedStores['status'] = newStatus;
        });
      } else {
        print("Bir hata oluştu");
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
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

  String? _chosenStoreCode;
  String? _chosenStoreName;
  String? _chosenStoreType;
  String? _chosenStoreCity;
  String? _chosenStorePhone;

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
                controller: storeTypeController,
                hintText: 'Mağaza Tipi',
                keyboardType: TextInputType.text,
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
                      "Durum",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem: store['status'] == 1 ? 'Aktif' : 'Pasif',
                      items: ['Aktif', 'Pasif'],
                      onChanged: (String? value) {},
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
        FutureBuilder(
          future: _getStores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var stores = snapshot.data;
              return Column(
                children: [
                  buildRow(
                      "Mağaza Kodu",
                      buildDropdownMenuItems(stores, 'storeCode'),
                      (value) => setState(() => _chosenStoreCode = value)),
                  SizedBox(height: 10),
                  buildRow(
                      "Mağaza Adı",
                      buildDropdownMenuItems(stores, 'storeName'),
                      (value) => setState(() => _chosenStoreName = value)),
                  SizedBox(height: 10),
                  buildRow(
                      "Mağaza Tipi",
                      buildDropdownMenuItems(stores, 'storeType'),
                      (value) => setState(() => _chosenStoreType = value)),
                  SizedBox(height: 10),
                  buildRow("Şehir", buildDropdownMenuItems(stores, 'city'),
                      (value) => setState(() => _chosenStoreCity = value)),
                  SizedBox(height: 10),
                  buildRow(
                      "Mağaza Telefon",
                      buildDropdownMenuItems(stores, 'storePhone'),
                      (value) => setState(() => _chosenStorePhone = value)),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 350),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: "Ara",
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: CustomButton(
                            buttonText: "Mağaza Ekle",
                            onPressed: () {
                              Navigator.pushNamed(context, '/addLocation');
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        SizedBox(height: 10),
        Container(
            margin: EdgeInsets.all(30),
            child: Text(
              "Mağazalar",
              style: TextStyle(
                  fontSize: Tokens.fontSize[9],
                  fontWeight: Tokens.fontWeight[6]),
            )),
        Padding(
          padding: EdgeInsets.all(20),
          child: FutureBuilder<List>(
            future: _getStores(),
            builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                List<TableRow> rows = snapshot.data!.map((store) {
                  return TableRow(children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['storeCode'],
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['storeName'],
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['storeType'].toString(),
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['city'],
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['storePhone'],
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        store['status'] == 1 ? 'Aktif' : 'Pasif',
                        style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: CustomButton(
                        buttonText: 'Düzenle',
                        textColor: Themes.blueColor,
                        buttonColor: Themes.whiteColor,
                        onPressed: () {
                          showModal(context, Themes.whiteColor, "", store);
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
                  border: TableBorder.all(color: Themes.blackColor),
                  children: [
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "MAĞAZA KODU",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "MAĞAZA ADI",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "MAĞAZA TİPİ",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "ŞEHİR",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "MAĞAZA TELEFON",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "DURUMU",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "DÜZENLE",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
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
    )));
  }
}
