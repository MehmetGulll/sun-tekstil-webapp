import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'package:http/http.dart' as http;
import 'package:toastification/toastification.dart';

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
        toastification.show(
          context: context,
          title: Text('Başarılı'),
          description: Text('Şifreniz başarıyla değiştirildi.'),
          icon: const Icon(Icons.check),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
        );
        Navigator.pushNamed(context, '/');
      } else if (response.statusCode == 401) {
        toastification.show(
          context: context,
          title: Text('Başarısız'),
          description:
              Text(' Lütfen eski şifrenizi doğru girdiğinizden emin olun.'),
          icon: const Icon(Icons.error_outline),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
        );
      } else {
        toastification.show(
          context: context,
          title: Text('Başarısız'),
          description: Text('Şifre değiştirme işlemi başarısız oldu.'),
          icon: const Icon(Icons.error_outline),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
        );
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Şifre Değiştir',
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24.0),
          constraints: BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Şifre Değiştirme",
                style: TextStyle(
                    fontSize: Tokens.fontSize[9],
                    fontWeight: Tokens.fontWeight[6]),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                  labelText: "Eski Şifre",
                  hintText: "Eski Şifrenizi Girin",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: "Yeni Şifre",
                  hintText: "Yeni Şifrenizi Girin",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Tekrar Yeni Şifre",
                  hintText: "Yeni Şifrenizi Tekrar Girin",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(height: 30),
              Tooltip(
                message: 'Şifreyi Değiştir',
                child: ElevatedButton(
                  child: Text(
                    "Şifre Değişikliğini Kaydet",
                    style: TextStyle(
                      fontSize: Tokens.fontSize[3],
                    ),
                  ),
                  onPressed: () {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      toastification.show(
                        context: context,
                        title: Text('Başarısız'),
                        description: Text('Şifreler uyuşmuyor.'),
                        icon: const Icon(Icons.error_outline),
                        type: ToastificationType.error,
                        style: ToastificationStyle.flatColored,
                        autoCloseDuration: const Duration(seconds: 3),
                        showProgressBar: true,
                        pauseOnHover: true,
                        dragToClose: true,
                        applyBlurEffect: true,
                      );
                    } else {
                      changePassword();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
