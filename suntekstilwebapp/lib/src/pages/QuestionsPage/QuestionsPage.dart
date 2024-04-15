import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';

class QuestionsPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final TextInputType keyboardType = TextInputType.text;
  void showModal(BuildContext context, Color backgroundColor, String text) {
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
                controller: TextEditingController(),
                hintText: 'Soru Kodu',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Soru',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
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
                      items: ['Evet', 'Hayır'],
                      onChanged: (String? value) {},
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
             Padding(
                padding: EdgeInsets.symmetric(horizontal: 600),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: "Düzenle",
                      onPressed: () {
                        print("Butona basıldı");
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: CustomButton(
                      buttonText: "Sil",
                      buttonColor: Themes.secondaryColor,
                      onPressed: () {
                        print("Silindi");
                        Navigator.of(context).pop();
                      },
                    ),
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
              Text(
                "SORU KODU",
                style: TextStyle(
                    color: Themes.blackColor, fontSize: Tokens.fontSize[3]),
              ),
              CustomInput(
                  controller: TextEditingController(),
                  hintText: "SORU KODU",
                  keyboardType: TextInputType.text),
              SizedBox(
                height: 50,
              ),
              Text(
                "SORU ADI",
                style: TextStyle(
                    color: Themes.blackColor, fontSize: Tokens.fontSize[3]),
              ),
              CustomInput(
                  controller: TextEditingController(),
                  hintText: "SORU ADI",
                  keyboardType: TextInputType.text),
              SizedBox(
                height: 50,
              ),
              Text(
                "SORU TİPİ",
                style: TextStyle(
                    color: Themes.blackColor, fontSize: Tokens.fontSize[3]),
              ),
              CustomInput(
                  controller: TextEditingController(),
                  hintText: "SORU TİPİ",
                  keyboardType: TextInputType.text),
              SizedBox(height: 15),
              CustomButton(
                  buttonText: 'Ara',
                  textColor: Themes.whiteColor,
                  buttonColor: Themes.blueColor,
                  onPressed: () {
                    print("Arama kısmı çalıştı");
                  }),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Table(
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
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
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
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "PUAN",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "DÜZENLE",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ))
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Tüm modeller reyona çıkarılmış mı?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            showModal(context, Themes.whiteColor, "");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "Depoda saklanana görsel malzemeler düzgün muhafaza ediliyor mu ??",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Depo düzenli mi?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            "Mağaza içerisindeki faceoutlarda uygun aksesuar kullanılmış mı?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Tüm modeller reyona çıkarılmış mı?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Tüm modeller reyona çıkarılmış mı?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "DG 3",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Tüm modeller reyona çıkarılmış mı?",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Evet/Hayır",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "5",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: CustomButton(
                          buttonText: 'Düzenle',
                          textColor: Themes.blueColor,
                          buttonColor: Themes.whiteColor,
                          onPressed: () {
                            print("Düzenleme ekranı açıldı");
                          },
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
