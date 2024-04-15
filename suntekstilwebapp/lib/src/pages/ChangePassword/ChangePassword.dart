import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class ChangePassword extends StatelessWidget {
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
                controller: TextEditingController(),
                hintText: "Eski Şifre",
                keyboardType: TextInputType.visiblePassword),
            SizedBox(
              height: 20,
            ),
            CustomInput(
                controller: TextEditingController(),
                hintText: "Yeni Şifre",
                keyboardType: TextInputType.visiblePassword),
            SizedBox(
              height: 20,
            ),
            CustomInput(
                controller: TextEditingController(),
                hintText: "Tekrar Yeni Şifre",
                keyboardType: TextInputType.visiblePassword),
            SizedBox(
              height: 20,
            ),
            CustomButton(
                buttonText: "Onayla",
                onPressed: () {
                  print("Onaylandı");
                })
          ],
        ),
      ),
    );
  }
}
