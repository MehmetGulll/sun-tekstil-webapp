import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final usernameController = TextEditingController();
  final userSurnameController = TextEditingController();
  final user_nameController = TextEditingController();
  final userEpostaController = TextEditingController();
  final passwordController = TextEditingController();
  Map<String, String> userRoles = {
    'Admin': '1',
    'Marka Yöneticisi': '2',
    'Bölge Müdürü': '3',
    'Görsel Yönetici': '4',
    'Mağaza Müdürü': '9'
  };
  List<String> getUserRoleItems() {
    return userRoles.keys.toList();
  }

  String? _chosenUserRole;
  bool isModalVisible = false;
  String modalMessage = "";
  Future<void> register(BuildContext context) async {
    print("Girdi");
    final response = await http.post(Uri.parse(ApiUrls.registerUrl), body: {
      'userName': usernameController.text,
      'userSurname': userSurnameController.text,
      'user_name': user_nameController.text,
      'userEposta': userEpostaController.text,
      'userPassword': passwordController.text,
      'userRole': userRoles[_chosenUserRole]
    });
    if (response.statusCode == 200) {
      print("Başarıyla güncellendi");
      String successMessage = "Kayıt Başarılı!!";
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
    } else if (response.statusCode == 400) {
      String errorMessage = "Kullanıcı zaten kayıtlı!!";
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Kayıt Et',
      body: SingleChildScrollView(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 500, vertical: 50),
        child: Column(
          children: [
            Text(
              "Kullanıcı Ekle",
              style: TextStyle(
                  fontSize: Tokens.fontSize[6],
                  fontWeight: Tokens.fontWeight[7]),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Ad",
                    style: TextStyle(
                        fontSize: Tokens.fontSize[4],
                        fontWeight: Tokens.fontWeight[6]),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                        controller: usernameController,
                        hintText: "Ad",
                        keyboardType: TextInputType.text)),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Soyad",
                      style: TextStyle(
                          fontSize: Tokens.fontSize[4],
                          fontWeight: Tokens.fontWeight[6])),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                      controller: userSurnameController,
                      hintText: "Soyad",
                      keyboardType: TextInputType.text,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Kullanıcı Adı",
                      style: TextStyle(
                          fontSize: Tokens.fontSize[4],
                          fontWeight: Tokens.fontWeight[6])),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                      controller: user_nameController,
                      hintText: "Kullanıcı Adı",
                      keyboardType: TextInputType.text,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("E Posta",
                      style: TextStyle(
                          fontSize: Tokens.fontSize[4],
                          fontWeight: Tokens.fontWeight[6])),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                      controller: userEpostaController,
                      hintText: "E Posta",
                      keyboardType: TextInputType.text,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Şifre",
                      style: TextStyle(
                          fontSize: Tokens.fontSize[4],
                          fontWeight: Tokens.fontWeight[6])),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                        controller: passwordController,
                        hintText: "Şifre",
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true)),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text("Rolü",
                      style: TextStyle(
                          fontSize: Tokens.fontSize[4],
                          fontWeight: Tokens.fontWeight[6])),
                ),
                Expanded(
                    flex: 3,
                    child: CustomDropdown(
                        items: getUserRoleItems(),
                        onChanged: (value) =>
                            setState(() => _chosenUserRole = value)))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(
                buttonText: "Kullanıcı Ekle",
                onPressed: () => register(context)),
            isModalVisible
                ? CustomModal(
                    backgroundColor: Themes.whiteColor,
                    text: '',
                    child: Column(
                      children: [
                        Text(modalMessage),
                        CustomButton(
                            buttonText: "Tamam",
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/officalUsers');
                            })
                      ],
                    ))
                : Container(),
          ],
        ),
      )),
    );
  }
}
