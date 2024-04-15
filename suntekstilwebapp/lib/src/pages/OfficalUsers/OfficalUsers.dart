import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Checkbox/Checkbox.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class OfficalUsers extends StatelessWidget {
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
                    "Yetkili Düzenle",
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
                hintText: 'Ad',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Soyad',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Kullanıcı Adı',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              ...[
                'Operasyon Direktörü',
                'Operasyon Müdürü',
                'Bölge Müdürü',
                'Lokasyon Müdürü',
                'Denetçi',
                'Marka Yöneticisi'
              ].map((role) => CustomCheckbox(title: role)).toList(),
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
                      items: ['Aktif', 'Pasif'],
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
              SizedBox(
                height: 50,
              ),
              Text(
                "Yetkili Kullanıcılar",
                style: TextStyle(
                    fontSize: Tokens.fontSize[9],
                    fontWeight: Tokens.fontWeight[6]),
              ),
              SizedBox(
                height: 50,
              ),
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
                          "AD SOYAD",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text("EMAİL",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "KULLANICI ADI ",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        color: Themes.yellowColor,
                        child: Text(
                          "DURUM",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "UNVAN",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          )),
                      Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "MARKA",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          )),
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
                          "Murat Göçken",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("murat.gokcen@jimmykey.com",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
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
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
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
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
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
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("murat.gokcen@jimmykey.com",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("murat.gokcen@jimmykey.com",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
                          "Murat Göçken",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text("murat.gokcen@jimmykey.com",
                            style: TextStyle(
                              fontWeight: Tokens.fontWeight[2],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "muratg",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Aktif",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Operasyon Direktörü",
                          style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Jimmy Key",
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
