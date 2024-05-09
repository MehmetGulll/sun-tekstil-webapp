import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Charts/BarCharts.dart';
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';

import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/components/Charts/BarCharts.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';

class Questions extends StatefulWidget {
  @override
  _QuestionsState createState() => _QuestionsState();
}

Widget buildColumn(BuildContext context, String label, List<String> items,
    ValueChanged<String?> onChanged) {
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
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _QuestionsState extends State<Questions> {
  final TextEditingController questionIdController = TextEditingController();
  final TextEditingController questionNameController = TextEditingController();
  final TextEditingController questionPointController = TextEditingController();
  final TextEditingController questionFilteredTypeController =
      TextEditingController();
  final TextEditingController questionFilteredNameController =
      TextEditingController();
  final TextInputType keyboardType = TextInputType.text;
  bool isFiltered = false;
  String? _chosenQuestionType;
  Map<String, String> _questionTypeList = {'Evet': '1', 'Hayır': '0'};
  Future<List<Map<String, dynamic>>> _getQuestions() async {
    if (!isFiltered) {
      String? token = await TokenHelper.getToken();
      print(token);
      var url = Uri.parse(ApiUrls.questionsUrl);
      var data = await http.get(url);

      var jsonData = json.decode(data.body) as List;
      print("Bütün data");
      print(jsonData);
        _questions.clear();
      _questions =
          jsonData.map((item) => item as Map<String, dynamic>).toList();
    }
    return _questions;
  }

  List<Map<String, dynamic>> _questions = [];
  Future<void> deleteQuestion(int id) async {
    print(id);
    final response =
        await http.delete(Uri.parse('${ApiUrls.deleteQuestion}/$id'));
    if (response.statusCode == 200) {
      print("Mağaza başarıyla silindi");
      setState(() {
        _questions.removeWhere((question) => question['id'] == id);
      });
    } else {
      print("Bir hata oluştu");
    }
  }

  Future<void> updateQuestion(
      BuildContext context, int id, Map<String, dynamic> question) async {
    var currentStatus = question['status'];
    var newStatus = currentStatus == 0 ? 1 : 0;
    question['status'] = newStatus;
    print(id);
    print("status");
    print(question['status']);

    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse('${ApiUrls.updateQuestion}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, String>{
        'soru_id': question['questionId'].toString(),
        'status': newStatus.toString()
      }),
    );
    if (response.statusCode == 200) {
      print("Başarıyla güncellendi");
      Navigator.pop(context);
      setState(() {
        var updatedQuestion = _questions
            .firstWhere((q) => q['questionId'] == question['questionId']);
        updatedQuestion['status'] = newStatus;
      });
    } else {
      print("Hata");
    }
  }

  Future<void> filteredQuestion(String queryType, String queryText) async {
    print(queryType);
    print(queryText);
    final response = await http
        .get(Uri.parse('${ApiUrls.filteredQuestion}?$queryType=$queryText'));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) as List;
      print("Filtreleme için");
      print(jsonData);
      setState(() {
        _questions.clear();

        _questions =
            jsonData.map((item) => item as Map<String, dynamic>).toList();
      });
    } else {
      print("Hata");
    }
  }
  void showModal(
      BuildContext context, Color backgroundColor, String text, Map question) {
    questionIdController.text = question['questionId'].toString();
    questionNameController.text = question['questionName'].toString();
    questionPointController.text = question['questionPoint'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomModal(
          backgroundColor: backgroundColor,
          text: text,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Soru Düzenle",
                    style: TextStyle(
                        fontSize: Tokens.fontSize[9],
                        fontWeight: Tokens.fontWeight[6]),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close))
                ],
              ),
             
              
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: questionNameController,
                hintText: 'Soru',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: questionPointController,
                hintText: 'Puan',
                keyboardType: TextInputType.text,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tipi",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem:
                          question['questionAnswer'] == 1 ? 'Evet' : 'Hayır',
                      items: ['Evet', 'Hayır'],
                      onChanged: (String? value) {},
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Durum",
                      style: TextStyle(fontSize: Tokens.fontSize[2]),
                    ),
                    CustomDropdown(
                      selectedItem: question['status'] == 1 ? 'Aktif' : 'Pasif',
                      items: ['Aktif', 'Pasif'],
                      onChanged: (String? value) {},
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 600),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "Düzenle",
                      onPressed: () async {
                        print("Butona basıldı");
                        await updateQuestion(context, question['questionId'],
                            Map<String, dynamic>.from(question));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 80),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "SORU ADI",
                style: TextStyle(
                    color: Themes.blackColor, fontSize: Tokens.fontSize[3]),
              ),
              CustomInput(
                  controller: questionFilteredNameController,
                  hintText: "SORU ADI",
                  keyboardType: TextInputType.text),
              SizedBox(
                height: 20,
              ),
              buildColumn(context, "SORU TİPİ", _questionTypeList.keys.toList(),
                  (value) => setState(() => _chosenQuestionType = value)),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      buttonText: 'Filtreleme',
                      textColor: Themes.whiteColor,
                      buttonColor: Themes.blueColor,
                      onPressed: () {
                        print("Arama kısmı çalıştı");
                        if (questionFilteredNameController.text.isNotEmpty) {
                          filteredQuestion(
                              'soru_adi', questionFilteredNameController.text);
                          isFiltered = true;
                        } else if (_chosenQuestionType != null) {
                          String? queryValue =
                              _questionTypeList[_chosenQuestionType];
                          filteredQuestion('soru_cevap', queryValue!);
                          isFiltered = true;
                        }
                      }),
                  SizedBox(
                    width: 20,
                  ),
                  CustomButton(
                      buttonText: 'Soru Ekle',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/addQuestion');
                      }),
                      SizedBox(width: 20,),
                  CustomButton(buttonText: 'Filtreleri Sil',buttonColor: Themes.secondaryColor, onPressed: ()async{
                    print("Filterleri temizleme");
                    isFiltered=false;
                   await _getQuestions();
                   setState(() {
                     
                   });
                  })
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: FutureBuilder<List>(
                  future: _getQuestions(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<TableRow> rows = snapshot.data!.map((question) {
                        return TableRow(children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              question['questionId'].toString(),
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              question['questionName'],
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              question['questionAnswer'] == 1
                                  ? "Evet"
                                  : "Hayır",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              question['questionPoint'].toString(),
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              question['status'] == 1 ? 'Aktif' : 'Pasif',
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: CustomButton(
                              buttonText: 'Düzenle',
                              textColor: Themes.blueColor,
                              buttonColor: Themes.whiteColor,
                              onPressed: () {
                                showModal(
                                    context, Themes.whiteColor, "", question);
                              },
                            ),
                          ),
                        ]);
                      }).toList();

                      return Table(
                        defaultColumnWidth: FlexColumnWidth(1),
                        columnWidths: {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        border: TableBorder.all(color: Themes.blackColor),
                        children: [
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "SORU KODU",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text("SORULAR",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "TİPİ",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "PUAN",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "DURUMU",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(8.0),
                                color: Themes.yellowColor,
                                child: Text(
                                  "DÜZENLE",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[2]),
                                ))
                          ]),
                          ...rows,
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
   
            ],
          ),
        ),
      ),
    );
  }
}
