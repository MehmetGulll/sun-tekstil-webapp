import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 0.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/homeImage.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            color: Themes.secondaryColor,
                            children: [
                              Text(
                                'Duyurular',
                                style: TextStyle(
                                  color: Themes.whiteColor,
                                  fontSize: Tokens.fontSize[2],
                                  fontWeight: Tokens.fontWeight[7],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomCard(
                            color: Themes.blueColor,
                            children: [
                              Text(
                                "Ziyaret Sayısı",
                                style: TextStyle(
                                  color: Themes.whiteColor,
                                  fontSize: Tokens.fontSize[2],
                                  fontWeight: Tokens.fontWeight[7],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    '0/4',
                                    style: TextStyle(
                                      color: Themes.whiteColor,
                                      fontSize: Tokens.fontSize[9],
                                      fontWeight: Tokens.fontWeight[5],
                                    ),
                                  ),
                                  Text(
                                    'Ziyaret Tamamlama Durumu',
                                    style: TextStyle(
                                      color: Themes.whiteColor,
                                      fontSize: Tokens.fontSize[1],
                                      fontWeight: Tokens.fontWeight[4],
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    '0%',
                                    style: TextStyle(
                                      color: Themes.whiteColor,
                                      fontSize: Tokens.fontSize[9],
                                      fontWeight: Tokens.fontWeight[5],
                                    ),
                                  ),
                                  Text(
                                    'Ziyaret Tamamlama Yüzdesi',
                                    style: TextStyle(
                                      color: Themes.whiteColor,
                                      fontSize: Tokens.fontSize[1],
                                      fontWeight: Tokens.fontWeight[4],
                                    ),
                                  ),
                                ],
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
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: CustomCard(
                      color: Themes.greenColor,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 50,
                          color: Themes.whiteColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "En Çok Aksiyonu Olan Lokasyonlar",
                          maxLines: 2,
                          style: TextStyle(
                            color: Themes.whiteColor,
                            fontSize: Tokens.fontSize[2],
                            fontWeight: Tokens.fontWeight[7],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CustomCard(
                      color: Themes.secondaryColor,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 50,
                          color: Themes.whiteColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "En Az Aksiyonu Olan Sorular",
                          maxLines: 2,
                          style: TextStyle(
                            color: Themes.whiteColor,
                            fontSize: Tokens.fontSize[2],
                            fontWeight: Tokens.fontWeight[7],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CustomCard(
                      color: Themes.purpleColor,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 50,
                          color: Themes.whiteColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Lokasyon Bazlı Kronik Hale Gelen Sorular",
                          maxLines: 2,
                          style: TextStyle(
                            color: Themes.whiteColor,
                            fontSize: Tokens.fontSize[2],
                            fontWeight: Tokens.fontWeight[7],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CustomCard(
                      color: Themes.blueColor,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 50,
                          color: Themes.whiteColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "En Çok Aksiyon Başlatılan Sorular",
                          maxLines: 2,
                          style: TextStyle(
                            color: Themes.whiteColor,
                            fontSize: Tokens.fontSize[2],
                            fontWeight: Tokens.fontWeight[7],
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
      ),
    );
  }
}
