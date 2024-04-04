import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 50.0), 
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.red,
                            child: Center(
                              child: Text('Text',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            child: Center(
                              child: Text('Text',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.circular(Tokens.borderRadius[1]!),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home,
                                    size: 50,
                                    color: Themes.whiteColor,
                                  ),
                                  Flexible(
                                      child: Text(
                                    "En Çok Aksiyon Olan Lokasyonlar",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Themes.whiteColor,
                                        fontSize: Tokens.fontSize[2],
                                        fontWeight: Tokens.fontWeight[7]),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Themes.secondaryColor,
                                  borderRadius: BorderRadius.circular(
                                      Tokens.borderRadius[1]!),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.home,
                                          size: 50,
                                          color: Themes.whiteColor,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "En Az Aksiyon Olan Lokasyonlar",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Themes.whiteColor,
                                              fontSize: Tokens.fontSize[2],
                                              fontWeight: Tokens.fontWeight[7]),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Themes.purpleColor,
                            borderRadius:
                                BorderRadius.circular(Tokens.borderRadius[1]!),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    size: 50,
                                    color: Themes.whiteColor,
                                  ),
                                  Flexible(
                                      child: Text(
                                    "Lokasyon Bazlı Kronik Hale Gelen Sorular",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Themes.whiteColor,
                                        fontSize: Tokens.fontSize[2],
                                        fontWeight: Tokens.fontWeight[7]),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Themes.blueColor,
                                  borderRadius: BorderRadius.circular(
                                      Tokens.borderRadius[1]!),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.bar_chart,
                                          size: 50,
                                          color: Themes.whiteColor,
                                        ),
                                        Flexible(
                                            child: Text(
                                          "En çok Aksiyon Başlatılan Sorular",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Themes.whiteColor,
                                              fontSize: Tokens.fontSize[2],
                                              fontWeight: Tokens.fontWeight[7]),
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
