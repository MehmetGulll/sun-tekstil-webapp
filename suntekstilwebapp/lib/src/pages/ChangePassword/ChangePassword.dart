import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> changePassword() async {
    String? username = await UsernameHelper.getUsername();
    try {
      final response =
          await http.post(Uri.parse(ApiUrls.changePassword), body: {
        'kullanici_adi': username,
        'eski_sifre': oldPasswordController.text,
        'yeni_sifre': newPasswordController.text
      });

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Themes.greenColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Şifre başarıyla değiştirildi!',
                          style: TextStyle(
                              color: Themes.whiteColor,
                              fontSize: Tokens.fontSize[7]),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        CustomButton(
                          buttonText: 'Tamam',
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      } else if (response.statusCode == 401) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Themes.accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Eski şifre aynı olamaz!',
                          style: TextStyle(
                              color: Themes.whiteColor,
                              fontSize: Tokens.fontSize[7]),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        CustomButton(
                          buttonText: 'Tamam',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Themes.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Oops bir şeyler ters gitti!',
                          style: TextStyle(
                              color: Themes.whiteColor,
                              fontSize: Tokens.fontSize[7]),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                        CustomButton(
                          buttonText: 'Tamam',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 80),
        child: Column(
          children: [
            Text(
              "Şifre Değiştirme",
              style: TextStyle(
                  fontSize: Tokens.fontSize[9],
                  fontWeight: Tokens.fontWeight[6]),
            ),
            SizedBox(
              height: 20,
            ),
            CustomInput(
              controller: oldPasswordController,
              hintText: "Eski Şifre",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            CustomInput(
              controller: newPasswordController,
              hintText: "Yeni Şifre",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            CustomInput(
              controller: confirmPasswordController,
              hintText: "Tekrar Yeni Şifre",
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(
                buttonText: "Onayla",
                onPressed: () {
                  changePassword();
                })
          ],
        ),
      ),
    );
  }
}
