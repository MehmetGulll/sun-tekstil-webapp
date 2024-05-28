import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

  // toastification.show(
  //     context: context,
  //     title: Text('Başarılı'),
  //     description: Text('Giriş işlemi başarılı bir şekilde gerçekleşti.'),
  //     icon: const Icon(Icons.check),
  //     type: ToastificationType.success,
  //     style: ToastificationStyle.flatColored,
  //     autoCloseDuration: const Duration(seconds: 3),
  //     showProgressBar: true,
  //     pauseOnHover: true,
  //     dragToClose: true,
  //     applyBlurEffect: true,
  //   );

class Login extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ASYNC TOAST FUNCTION
  void toast (BuildContext context, String title, String description, IconData icon, ToastificationType type) async {
    toastification.show(
      context: context,
      title: Text(title),
      description: Text(description),
      icon: Icon(icon),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

Future<void> login(BuildContext context) async {
  final response = await http.post(Uri.parse(ApiUrls.panelLogin), body: {
    'kullanici_adi': usernameController.text,
    'sifre': passwordController.text
  });
  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    String token = responseBody['token'];
    String username = responseBody['user']['kullanici_adi'];
    int rol = responseBody['user']['rol_id'];
    int currentUserId = responseBody['user']['id'];

    Auth auth = Provider.of<Auth>(context, listen: false);
    auth.token = token;
    auth.notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("username", username);
    await prefs.setInt("currentUserId", currentUserId);
    await prefs.setInt("rol", rol);

    String userNameAndSurname = responseBody['user']['ad'] + ' ' + responseBody['user']['soyad'];

    Navigator.pushReplacementNamed(context, '/home');
    toast(
      context,
      'Giriş işlemi başarılı bir şekilde gerçekleşti.',
      'Hoşgeldiniz, $userNameAndSurname',
      Icons.check,
      ToastificationType.success
    );
  } else {
    toast(
      context,
      'Hata',
      'Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.',
      Icons.error,
      ToastificationType.error
    );
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
                    buttonColor: Themes.cardBackgroundColor,
                    textColor: Themes.blackColor,
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
