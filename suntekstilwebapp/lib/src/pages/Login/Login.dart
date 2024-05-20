import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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
      String username = responseBody['user']['kullanici_adi'];
      int rol = responseBody['user']['rol_id'];
      int currentUserId = responseBody['user']['id'];

      print("rol kısmı $rol");
      print(responseBody['token']);
      print("username");
      print(username);

      Auth auth = Provider.of<Auth>(context, listen: false);
      auth.token = token;
      auth.notifyListeners();

      Provider.of<Auth>(context, listen: false).token = token;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("username", username);
      await prefs.setInt("currentUserId", currentUserId);
      await prefs.setInt("rol",rol);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      String errorMessage = "Bir hata oluştu!!";
      if (response.body.isNotEmpty) {
        errorMessage = response.body;
      }
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorMessage: errorMessage,
              errorIcon: Icons.person_off,
              onPressed: (){
                Navigator.of(context).pop();
              },
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            login(context);
          }
        },
        child: Container(
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
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],  
          ),
        ),
      ),
    );
  }
}
