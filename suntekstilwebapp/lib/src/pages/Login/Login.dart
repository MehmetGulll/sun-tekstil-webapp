import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  void toast(BuildContext context, String title, String description,
      IconData icon, ToastificationType type) async {
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

      String userNameAndSurname =
          responseBody['user']['ad'] + ' ' + responseBody['user']['soyad'];

      Navigator.pushReplacementNamed(context, '/home');
      toast(
          context,
          'Giriş işlemi başarılı bir şekilde gerçekleşti.',
          'Hoşgeldiniz, $userNameAndSurname',
          Icons.check,
          ToastificationType.success);
    } else {
      toast(
          context,
          'Hata',
          'Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.',
          Icons.error,
          ToastificationType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Kullanıcı Adı:",
                      ),
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (_) => login(context),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Şifre:",
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscureText,
                      onFieldSubmitted: (_) => login(context),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 175, 
                    child: ElevatedButton(
                      onPressed: () => login(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login), 
                          SizedBox(
                              width:
                                  8),
                          Text(
                            'Giriş',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
