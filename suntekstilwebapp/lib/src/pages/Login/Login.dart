import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';

class Login extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final response = await http.post(Uri.parse(ApiUrls.loginUrl), body: {
      'user_name': usernameController.text,
      'userPassword': passwordController.text
    });

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print("Access Failed ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 500, vertical: 50),
        child: Column(
          children: [
            SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1 / 0.4,
              child: FractionallySizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/homeImage.jpeg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Kullanıcı Adı",
                    style: TextStyle(
                        fontSize: Tokens.fontSize[4],
                        fontWeight: Tokens.fontWeight[6]),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: CustomInput(
                        controller: usernameController,
                        hintText: "Kullanıcı Adı",
                        keyboardType: TextInputType.text)),
              ],
            ),
            SizedBox(height: 20),
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
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(buttonText: "Giriş", onPressed: () => login(context)),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
