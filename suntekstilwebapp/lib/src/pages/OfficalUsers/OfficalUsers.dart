import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
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
                            showModal(
                                context, Themes.yellowColor, "Modal Açıldı");
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
