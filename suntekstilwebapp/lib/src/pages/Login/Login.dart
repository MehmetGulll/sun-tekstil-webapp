import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    print(usernameController);
    print(passwordController);
    final response = await http.post(Uri.parse(ApiUrls.loginUrl), body: {
      'kullanici_adi': usernameController.text,
      'sifre': passwordController.text
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String token = responseBody['token'];
      print(responseBody['token']);

      Auth auth = Provider.of<Auth>(context, listen: false);
      auth.token = token;
      auth.notifyListeners();

      Provider.of<Auth>(context, listen: false).token = token;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

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
                      obscureText: true,
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                    buttonText: "Giriş", onPressed: () => login(context)),
                SizedBox(
                  width: 20,
                ),
                CustomButton(
                    buttonText: "Kayıt Ol",
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/register'))
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
