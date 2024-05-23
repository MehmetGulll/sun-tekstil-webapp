import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
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
        String successMessage = "Şifre başarıyla değişti!!";
        if (response.body.isNotEmpty) {
          successMessage = response.body;
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  successMessage: successMessage,
                  successIcon: Icons.check,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  });
            });
      } else if (response.statusCode == 401) {
        String errorMessage = "Bir hata oluştu!!";
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
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
        String errorMessage = "Oops bir şeyler ters gitti!";
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
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
    } catch (e) {
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Şifre Değiştir',
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
                buttonColor: Themes.cardBackgroundColor,
                textColor: Themes.blackColor,
                onPressed: () {
                  changePassword();
                })
          ],
        ),
      ),
    );
  }
}
