import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Checkbox/Checkbox.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class OfficalUsers extends StatefulWidget {
  @override
  _OfficalUsers createState() => _OfficalUsers();
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

class _OfficalUsers extends State<OfficalUsers> {
  TextEditingController adController = TextEditingController();
  TextEditingController soyadController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController unvanController = TextEditingController();
  Map<String, int> roller = {
    'Admin': 1,
    'Marka Yöneticisi': 2,
    'Bölge Müdürü': 3,
    'Görsel Yönetici': 4,
    'Mağaza Müdürü': 5,
    'Yetkisiz': 6,
  };

  List<Map<String, dynamic>> _users = [];
  Future<List<Map<String, dynamic>>> _getUsers() async {
    var url = Uri.parse(ApiUrls.getUsers);
    var data = await http.get(url);

    var jsonData = json.decode(data.body) as List;
    print(jsonData);
    int? currentUserId = await currentUserIdHelper.getCurrentUserId();

    _users = jsonData
        .map((item) => item as Map<String, dynamic>)
        .where((user) => user['id'] != currentUserId)
        .toList();

    return _users;
  }

  Future<void> updateUser(
      BuildContext context, int id, Map<String, dynamic> user) async {
    var currentStatus = user['status'] == 1 ? 'Pasif' : 'Aktif';
    var newStatus = currentStatus == 'Aktif' ? 0 : 1;
    var currentUnvan = user['rol_adi'];
    print(user['id']);
    print(adController.text);
    print(soyadController.text);
    print(emailController.text);
    print(roller[unvanController.text]);
    print(newStatus);
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse('${ApiUrls.updateOfficalUser}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, String>{
        'userId': id.toString(),
        'newAd': adController.text,
        'newSoyad': soyadController.text,
        'newEmail': emailController.text,
        'newStatus': newStatus.toString(),
        'newRol': roller[unvanController.text].toString()
      }),
    );
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
                Navigator.pushReplacementNamed(context, '/officalUsers');
              },
            );
          });

      setState(() {
        var updatedUser = _users.firstWhere((u) => u['id'] == user['id']);
        updatedUser['status'] = newStatus;
      });
    } else {
      print("Hata");
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
  }

  Future<void> uploadImage(Uint8List? bytes, String fileName) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:5000/upload'));
    request.files
        .add(http.MultipartFile.fromBytes('photo', bytes!, filename: fileName));
    var res = await request.send();
    if (res.statusCode == 200) {
      print("Upload successful");
    } else {
      print("Upload failed");
    }
  }

String? _fileName;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        Uint8List? bytes = result.files.first.bytes;
        _fileName = result.files.first.name!;
        print("result is: $result");
        print("result files first bytes : ${bytes}");
        print("_fileName: $_fileName");
      });
    }
  }

  void showModal(
      BuildContext context, Color backgroundColor, String text, Map user) {
    adController.text = user['ad'];
    soyadController.text = user['soyad'];
    emailController.text = user['eposta'];
    unvanController.text = user['rol_adi'];
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
                    "Yetkili Düzenle",
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
                controller: adController,
                hintText: 'Ad',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: soyadController,
                hintText: 'Soyad',
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: emailController,
                hintText: 'E mail',
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
                      selectedItem: user['status'] == 1 ? 'Aktif' : 'Pasif',
                      items: ['Aktif', 'Pasif'],
                      onChanged: (String? value) {
                        user['status'] = value == 'Aktif' ? 1:0;
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
                      "Unvan",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem: unvanController.text,
                      items: roller.keys.toList(),
                      onChanged: (String? value) {
                        unvanController.text = value!;
                        print("unvan id $value");
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 600),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "Düzenle",
                      onPressed: () async {
                        print("Butona basıldı");
                        await updateUser(context, user['id'],
                            Map<String, dynamic>.from(user));
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
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 80),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "Yetkili Kullanıcılar",
                style: TextStyle(
                    fontSize: Tokens.fontSize[9],
                    fontWeight: Tokens.fontWeight[6]),
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    Uint8List fileBytes = result.files.first.bytes!;
                    String fileName = result.files.first.name;

                    uploadImage(fileBytes, fileName);
                  } else {
                    print('No file selected');
                  }
                },
                child: Text('Select a file'),
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: FutureBuilder<List>(
                  future: _getUsers(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<TableRow> user =
                          snapshot.data!.map<TableRow>((user) {
                        return TableRow(children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              user['ad'],
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              user['soyad'],
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(user['eposta'],
                                style: TextStyle(
                                  fontWeight: Tokens.fontWeight[2],
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              user['kullanici_adi'],
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              user['status'] == 1 ? 'Aktif' : 'Pasif',
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              user['rol_adi'],
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Jimmy Key",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: CustomButton(
                              buttonText: 'Düzenle',
                              textColor: Themes.blueColor,
                              buttonColor: Themes.whiteColor,
                              onPressed: () {
                                showModal(context, Themes.whiteColor, "", user);
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
                        },
                        border: TableBorder.all(color: Themes.blackColor),
                        children: [
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "AD",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "SOYAD",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text("EMAİL",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "KULLANICI ADI ",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "DURUM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(8.0),
                                color: Themes.yellowColor,
                                child: Text(
                                  "UNVAN",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[2]),
                                )),
                            Container(
                                padding: EdgeInsets.all(8.0),
                                color: Themes.yellowColor,
                                child: Text(
                                  "MARKA",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[2]),
                                )),
                            Container(
                                padding: EdgeInsets.all(8.0),
                                color: Themes.yellowColor,
                                child: Text(
                                  "DÜZENLE",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[2]),
                                ))
                          ]),
                          ...user,
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                  buttonText: "Yeni Kullanici Ekle",
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/register'))
            ],
          ),
        ),
      ),
    );
  }
}
