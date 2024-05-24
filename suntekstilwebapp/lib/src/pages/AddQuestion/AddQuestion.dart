import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';

class AddQuestion extends StatefulWidget {
  @override
  _AddQuestionState createState() => _AddQuestionState();
}

Widget buildColumn(BuildContext context, String label,
    Map<String, String> items, ValueChanged<String?> onChanged) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Tokens.fontSize[4]),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: CustomDropdown(
            items: items.keys.toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _AddQuestionState extends State<AddQuestion> {
  final TextEditingController questionNameController = TextEditingController();
  final TextEditingController questionAnswerController =
      TextEditingController();
  final TextEditingController questionPointController = TextEditingController();
  @override
  // void dispose() {
  //   // burası dropdown değişince input içi değişmesin diye konuldu
  //   storeCodeController.dispose();
  //   storeNameController.dispose();
  //   storeCityController.dispose();
  //   storePhoneNumberController.dispose();
  //   storeWidthController.dispose();
  //   super.dispose();
  // }

  final TextInputType keyboardType = TextInputType.text;

  String? _chosenQuestionState;
  String? _chosenInspectionType;
  String? _chosenQuestionAnswer;
  Map<String, String> inspectionTypes = {
    'Bölge Müdürü Haftalık Kontrol': '1',
    'Bölge Müdürü Aylık Kontrol': '2',
    'Görsel Denetim': '3',
    'Mağaza Denetim': '4'
  };
  Map<String, String> questionAnswer = {'Evet': '0', 'Hayır': '1'};
  Map<String, String> questionState = {'Aktif': '1', 'Pasif': '0'};

  List<String> _storeManagerType = [
    '1',
    '2',
  ];


  Future<void> addQuestion(BuildContext context) async {
    String? token = await TokenHelper.getToken();
    print(questionNameController);
    print(questionNameController);
    print(questionPointController);
    print(questionAnswer[_chosenQuestionAnswer]);
    print(questionState[_chosenQuestionState]);

    try {
      final response = await http.post(Uri.parse(ApiUrls.addQuestion),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '$token'
          },
          body: jsonEncode({
            'soru_adi': questionNameController.text,
            'soru_cevap': _chosenQuestionAnswer != null
                ? int.parse(questionAnswer[_chosenQuestionAnswer!] ?? '0')
                : null,
            'soru_puan': int.parse(questionPointController.text),
            'denetim_tip_id': _chosenInspectionType != null &&
                    inspectionTypes[_chosenInspectionType] != null
                ? int.parse(inspectionTypes[_chosenInspectionType]!)
                : null,
          }));

      if (response.statusCode == 201) {
        print("Soru Eklendi");
        String successMessage = "Soru Eklendi!!";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                successMessage: successMessage,
                successIcon: Icons.check,
                onPressed: () {
                  Navigator.pushNamed(context, '/questions');
                },
              );
            });
      } else {
        print("Soru Eklenemedi");
        String errorMessage = "Soru Ekleme Sırasında Hata!!";
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(
                errorMessage: errorMessage,
                errorIcon: Icons.error,
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            });
        print("Bir hata oluştu");
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Soru Ekle',
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            children: [
              Column(
                children: [
                  Text("Soru Adı",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: questionNameController,
                      hintText: 'Soru Adı',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Soru Cevap", questionAnswer,
                  (value) => setState(() => _chosenQuestionAnswer = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Denetim Tipi", inspectionTypes,
                  (value) => setState(() => _chosenInspectionType = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Soru Durumu", questionState,
                  (value) => setState(() => _chosenQuestionState = value)),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Soru Puan",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: questionPointController,
                      hintText: 'Soru Puan',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                      buttonText: 'Ekle',
                      textColor: Themes.blackColor,
                      buttonColor: Themes.cardBackgroundColor,
                      onPressed: () {
                        addQuestion(context);
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
