import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';

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
                  child: Container(
                      margin: EdgeInsets.only(top: 45),
                      child: Container(
                        child: Row(
                          children: [
                            CustomCard(
                              color: Themes.secondaryColor,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 25),
                                  child: Text(
                                    'Duyurular',
                                    style: TextStyle(
                                        color: Themes.whiteColor,
                                        fontSize: Tokens.fontSize[2],
                                        fontWeight: Tokens.fontWeight[7]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Themes.blueColor,
                                      borderRadius: BorderRadius.circular(
                                          Tokens.borderRadius[1]!)),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 25),
                                      child: Column(
                                        children: [
                                          CustomCard(
                                              color: Themes.blueColor,
                                              children: [
                                                Text(
                                                  "Ziyaret Sayısı",
                                                  style: TextStyle(
                                                      color: Themes.whiteColor,
                                                      fontSize:
                                                          Tokens.fontSize[2],
                                                      fontWeight:
                                                          Tokens.fontWeight[7]),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            '0/4',
                                                            style: TextStyle(
                                                                color: Themes
                                                                    .whiteColor,
                                                                fontSize: Tokens
                                                                        .fontSize[
                                                                    9],
                                                                fontWeight: Tokens
                                                                    .fontWeight[5]),
                                                          ),
                                                          Text(
                                                            'Ziyaret Tamamlama Durumu',
                                                            style: TextStyle(
                                                                color: Themes
                                                                    .whiteColor,
                                                                fontSize: Tokens
                                                                        .fontSize[
                                                                    1],
                                                                fontWeight: Tokens
                                                                    .fontWeight[4]),
                                                          ),
                                                          SizedBox(
                                                            height: 25,
                                                          ),
                                                          Text(
                                                            '0%',
                                                            style: TextStyle(
                                                                color: Themes
                                                                    .whiteColor,
                                                                fontSize: Tokens
                                                                        .fontSize[
                                                                    9],
                                                                fontWeight: Tokens
                                                                    .fontWeight[5]),
                                                          ),
                                                          Text(
                                                            'Ziyaret Tamamlama Yüzdesi',
                                                            style: TextStyle(
                                                                color: Themes
                                                                    .whiteColor,
                                                                fontSize: Tokens
                                                                        .fontSize[
                                                                    1],
                                                                fontWeight: Tokens
                                                                    .fontWeight[4]),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ])
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                      )),
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
                      CustomCard(
                        color: Colors.green,
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
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomCard(
                        color: Themes.secondaryColor,
                        children: [
                          Icon(
                            Icons.home,
                            size: 50,
                            color: Themes.whiteColor,
                          ),
                          Flexible(
                            child: Text(
                              "En Az Aksiyonu Olan Lokasyonlar",
                              maxLines: 1,
                              style: TextStyle(
                                  color: Themes.whiteColor,
                                  fontSize: Tokens.fontSize[2],
                                  fontWeight: Tokens.fontWeight[7]),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Row(
                    children: [
                      CustomCard(
                        color: Themes.purpleColor,
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
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            CustomCard(
                              color: Themes.blueColor,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 50,
                                  color: Themes.whiteColor,
                                ),
                                Flexible(
                                  child: Text(
                                    "En Çok Aksiyon Başlatılan Sorular",
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Themes.whiteColor,
                                        fontSize: Tokens.fontSize[2],
                                        fontWeight: Tokens.fontWeight[7]),
                                  ),
                                ),
                              ],
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
