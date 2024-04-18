import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
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
  bool isModalVisible = false;
  String modalMessage = "";
  Future<void> register(BuildContext context) async {
    final response = await http.post(Uri.parse(ApiUrls.registerUrl), body: {
      'userName': usernameController.text,
      'userSurname': userSurnameController.text,
      'user_name': user_nameController.text,
      'userEposta': userEpostaController.text,
      'userPassword': passwordController.text
    });
    if (response.statusCode == 200) {
      setState(() {
        isModalVisible = true;
      });
      modalMessage="Kayıt Başarılı";
    }else if(response.statusCode == 400){
      setState(() {
        isModalVisible=true;
        modalMessage = "Bu kullanıcı adı zaten kayıtlı";
      });
    }
     else {
      print("Kayıt Başarısız");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 500, vertical: 50),
        child: Column(
          children: [
            Text(
              "Kayıt Ol",
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
                      keyboardType: TextInputType.text,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(
                buttonText: "Kayıt ol", onPressed: () => register(context)),
            isModalVisible
                ? CustomModal(
                    backgroundColor: Themes.whiteColor,
                    text: '',
                    child: Column(
                      children: [
                        
                        Text(modalMessage),
                        CustomButton(
                            buttonText: "Giriş Ekranına Dön",
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/');
                            })
                      ],
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
