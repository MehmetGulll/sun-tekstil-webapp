import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';

class Home extends StatelessWidget {

   Future<void> fetchData(BuildContext context,String id) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? token = auth.token;
  final intId = int.parse(id);
  final url = Uri.parse('${ApiUrls.getLastFiveInspections}/$intId');
    
  print(token);
  try {
    print("ATAKAN2");
    final response = await http.get(url, headers: {
      'Authorization':
          'Bearer $token',
    });
  
    if (response.statusCode == 200) {
      print("ATAKAN3");
      final data = json.decode(response.body);
      print('ATAKAN4 Response data: $data');
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error occurred: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    fetchData(context,"5");
    return CustomScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
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
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Themes.greyColor.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomCard(
                        color: Themes.cardBackgroundColor,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.announcement_outlined,
                                size: 30,
                                color: Themes.cardTextColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Duyurular',
                                style: TextStyle(
                                  color: Themes.cardTextColor,
                                  fontSize: Tokens.fontSize[3],
                                  fontWeight: Tokens.fontWeight[7],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Themes.greyColor.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomCard(
                        color: Themes.cardBackgroundColor,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    size: 30,
                                    color: Themes.cardTextColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Ziyaret Sayısı",
                                    style: TextStyle(
                                      color: Themes.cardTextColor,
                                      fontSize: Tokens.fontSize[3],
                                      fontWeight: Tokens.fontWeight[7],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '1/4',
                                    style: TextStyle(
                                      color: Themes.cardTextColor,
                                      fontSize: Tokens.fontSize[6],
                                      fontWeight: Tokens.fontWeight[5],
                                    ),
                                  ),
                                  Text(
                                    'Ziyaret Tamamlama Durumu',
                                    style: TextStyle(
                                      color: Themes.cardTextColor,
                                      fontSize: Tokens.fontSize[1],
                                      fontWeight: Tokens.fontWeight[4],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '25%',
                                    style: TextStyle(
                                      color: Themes.cardTextColor,
                                      fontSize: Tokens.fontSize[6],
                                      fontWeight: Tokens.fontWeight[5],
                                    ),
                                  ),
                                  Text(
                                    'Ziyaret Tamamlama Yüzdesi',
                                    style: TextStyle(
                                      color: Themes.cardTextColor,
                                      fontSize: Tokens.fontSize[1],
                                      fontWeight: Tokens.fontWeight[4],
                                    ),
                                  ),
                                ],
                              ),
                           
                                  ]
                              )
                              ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Themes.greyColor.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomCard(
                              color: Themes.cardBackgroundColor,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 30,
                                      color: Themes.cardTextColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "En Çok Aksiyonu Olan Lokasyonlar",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Themes.cardTextColor,
                                        fontSize: Tokens.fontSize[3],
                                        fontWeight: Tokens.fontWeight[7],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Themes.greyColor.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomCard(
                              color: Themes.cardBackgroundColor,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.question_answer_outlined,
                                      size: 30,
                                      color: Themes.cardTextColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "En Az Aksiyonu Olan Sorular",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Themes.cardTextColor,
                                        fontSize: Tokens.fontSize[3],
                                        fontWeight: Tokens.fontWeight[7],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Themes.greyColor.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomCard(
                              color: Themes.cardBackgroundColor,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.dashboard_outlined,
                                      size: 30,
                                      color: Themes.cardTextColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Lokasyon Bazlı Kronik Hale Gelen Sorular",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Themes.cardTextColor,
                                        fontSize: Tokens.fontSize[3],
                                        fontWeight: Tokens.fontWeight[7],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Themes.greyColor.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CustomCard(
                              color: Themes.cardBackgroundColor,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 30,
                                      color: Themes.cardTextColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "En Çok Aksiyon Başlatılan Sorular",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Themes.cardTextColor,
                                        fontSize: Tokens.fontSize[3],
                                        fontWeight: Tokens.fontWeight[7],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
