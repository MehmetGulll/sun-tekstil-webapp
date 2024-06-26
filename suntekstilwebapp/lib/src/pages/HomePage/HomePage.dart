import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokenDecode.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/pages/SuccessRate/SuccessRate.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class Home extends StatelessWidget {
  Future<Widget> fetchData(BuildContext context, String token) async {
    try {
      String? token = await TokenHelper.getToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userID = await currentUserIdHelper.getCurrentUserId();
      print('userID: $userID');

      final url = Uri.parse('${ApiUrls.getLastThreeInspections}/$userID');
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data: $data');
        List<Widget> announcements = [];
        for (var inspection in data) {
          String inspectionType = inspection['denetim_tipi'];
          String inspectionDate = inspection['denetim_tarihi'];
          inspectionDate = inspectionDate.split('-').reversed.join('.');
          String store = inspection['magaza'];
          String auditor = inspection['denetci'];
          String status =
              inspection['status'] == 0 ? 'Tamamlandı' : 'Tamamlanmadı';
          String score = inspection['alinan_puan'] == ''
              ? ''
              : inspection['alinan_puan'].toString();

          Widget announcementWidget = Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: ListTile(
              title: Text('Denetim Türü: $inspectionType'),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '• Mağaza: $store Denetçi: $auditor Denetim Tarihi $inspectionDate Durum: $status Alınan Puan: $score',
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          );
          announcements.add(announcementWidget);
        }
        CustomCard announcementCard = CustomCard(
          color: Themes.cardBackgroundColor,
          children: announcements,
        );
        print('Announcements: $announcements');
        return announcementCard;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return Text('Error fetching data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
      return Text('Henüz Denetim Yapılmadı');
    }
  }

  List<Map<String, dynamic>> _stores = [];
  Future<int> _getStoresCount() async {
    var url = Uri.parse(ApiUrls.storesUrl);
    var data = await http.get(url);
    var jsonData = json.decode(data.body) as List;
    print(jsonData);

    _stores = jsonData.map((item) => item as Map<String, dynamic>).toList();
    int storesCount = _stores.length;

    return storesCount;
  }

  Future<Map<String, dynamic>> ziyaretSayisi() async {
    try {
      String? token = await TokenHelper.getToken();
      Map<String, dynamic> decodedToken = decodeJwt(token!);
      int intId = decodedToken['id'];
      final url = Uri.parse('${ApiUrls.getInspectionCompletionStatus}/$intId');

      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      print('Error occurred: $error');
      return {};
    }
  }

  List<Map<String, dynamic>> _kronikSorularData = [];
  Future<Map<String, dynamic>> kronikSorular() async {
    try {
      String? token = await TokenHelper.getToken();
      final url = Uri.parse('${ApiUrls.getFrequentlyWrongQuestions}');

      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Data kronikSorular: $data');
        _kronikSorularData = data as List<Map<String, dynamic>>;

        Map<String, dynamic> kronikSorularData = {
          'kronikSorular': _kronikSorularData,
        };

        print('kronikSorularData: $kronikSorularData');
        return  kronikSorularData;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      print('Error occurred: $error');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenHelper.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error fetching token: ${snapshot.error}');
        } else {
          String? token = snapshot.data;
          return FutureBuilder(
            future: fetchData(context, token!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error fetching data: ${snapshot.error}');
              } else {
                Widget announcementCard = snapshot.data as Widget;
                return FutureBuilder(
                  future: ziyaretSayisi(),
                  builder: (context, ziyaretSnapshot) {
                    if (ziyaretSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (ziyaretSnapshot.hasError) {
                      return Text(
                          'Error fetching data: ${ziyaretSnapshot.error}');
                    } else {
                      Map<String, dynamic> ziyaretData =
                          ziyaretSnapshot.data as Map<String, dynamic>;

                      return FutureBuilder(
                        future: kronikSorular(),
                        builder: (context, kronikSnapshot) {
                          if (kronikSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (kronikSnapshot.hasError) {
                            return Text(
                                'Error fetching data: ${kronikSnapshot.error}');
                          } else {
                            return CustomScaffold(
                              body: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1 / 0.42,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                'assets/homeImage.jpeg',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Themes.borderColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: CustomCard(
                                                      color: Themes
                                                          .cardBackgroundColor,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .announcement_outlined,
                                                              size: 30,
                                                              color: Themes
                                                                  .cardTextColor,
                                                            ),
                                                            Text(
                                                              'En Son 3 Denetim',
                                                              style: TextStyle(
                                                                color: Themes
                                                                    .cardTextColor,
                                                                fontSize: Tokens
                                                                    .fontSize[3],
                                                                fontWeight: Tokens
                                                                    .fontWeight[7],
                                                              ),
                                                              softWrap: true,
                                                            ),
                                                          ],
                                                        ),
                                                        announcementCard,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Themes.borderColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                color: Themes
                                                                    .borderColor,
                                                                width: 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: CustomCard(
                                                              color: Themes
                                                                  .cardBackgroundColor,
                                                              children: [
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .analytics_outlined,
                                                                          size:
                                                                              30,
                                                                          color:
                                                                              Themes.cardTextColor,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Text(
                                                                          "Ziyaret Sayısı",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Themes.cardTextColor,
                                                                            fontSize:
                                                                                Tokens.fontSize[3],
                                                                            fontWeight:
                                                                                Tokens.fontWeight[7],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  '${ziyaretData['completedCount']}/${ziyaretData['totalCount']}',
                                                                                  style: TextStyle(
                                                                                    color: Themes.cardTextColor,
                                                                                    fontSize: Tokens.fontSize[6],
                                                                                    fontWeight: Tokens.fontWeight[5],
                                                                                  ),
                                                                                ),
                                                                                Icon(
                                                                                  Icons.arrow_right,
                                                                                  size: 35,
                                                                                ),
                                                                                Text(
                                                                                  '${ziyaretData['completionPercentage'] != null ? ziyaretData['completionPercentage'].toStringAsFixed(2) : '0.00'}%',
                                                                                  style: TextStyle(
                                                                                    color: Themes.cardTextColor,
                                                                                    fontSize: Tokens.fontSize[6],
                                                                                    fontWeight: Tokens.fontWeight[5],
                                                                                  ),
                                                                                ),
                                                                              ],
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
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            16),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 20,
                                                                            ),
                                                                            CustomButton(
                                                                                buttonText: "Başarı oranlarını gör",
                                                                                buttonColor: Themes.dividerColor,
                                                                                textColor: Themes.blackColor,
                                                                                onPressed: () {
                                                                                  Navigator.pushReplacement(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => SuccessRate(),
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                            FutureBuilder(
                                                                                future: _getStoresCount(),
                                                                                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                    return CircularProgressIndicator();
                                                                                  } else if (snapshot.hasError) {
                                                                                    return Text('Hata:${snapshot.error}');
                                                                                  } else {
                                                                                    String message = '';
                                                                                    if (snapshot.data != null) {
                                                                                      if (snapshot.data == 0) {
                                                                                        message = 'Aktif Lokasyon Bulunamadı';
                                                                                      } else {
                                                                                        message = 'Aktif Lokasyon Sayısı: ${snapshot.data}';
                                                                                      }
                                                                                    }

                                                                                    return Column(
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          height: 20,
                                                                                        ),
                                                                                        Text(
                                                                                          message,
                                                                                          maxLines: 2,
                                                                                          textAlign: TextAlign.center,
                                                                                          style: TextStyle(color: Themes.cardTextColor, fontSize: Tokens.fontSize[3], fontWeight: Tokens.fontWeight[7]),
                                                                                        )
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                })
                                                                          ],
                                                                        ),
                                                                      ],
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
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Themes.borderColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: CustomCard(
                                                      color: Themes
                                                          .cardBackgroundColor,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .location_on_outlined,
                                                              size: 30,
                                                              color: Themes
                                                                  .cardTextColor,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "En Çok Aksiyonu Olan Mağazalar",
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Themes
                                                                    .cardTextColor,
                                                                fontSize: Tokens
                                                                    .fontSize[3],
                                                                fontWeight: Tokens
                                                                    .fontWeight[7],
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
                                                    margin: EdgeInsets.only(
                                                        left: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Themes.borderColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: CustomCard(
                                                      color: Themes
                                                          .cardBackgroundColor,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .assignment_outlined,
                                                              size: 30,
                                                              color: Themes
                                                                  .cardTextColor,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "En Çok Aksiyonu Olan Sorular",
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Themes
                                                                    .cardTextColor,
                                                                fontSize: Tokens
                                                                    .fontSize[3],
                                                                fontWeight: Tokens
                                                                    .fontWeight[7],
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
                                                    margin: EdgeInsets.only(
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            Themes.borderColor,
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: CustomCard(
                                                      color: Themes
                                                          .cardBackgroundColor,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.dashboard_outlined,
                                                                  size: 30,
                                                                  color: Themes
                                                                      .cardTextColor,
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  'Kronik Hale Gelen Sorular',
                                                                  maxLines: 2,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Themes
                                                                        .cardTextColor,
                                                                    fontSize:
                                                                        Tokens.fontSize[
                                                                            3],
                                                                    fontWeight:
                                                                        Tokens.fontWeight[
                                                                            7],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 16),
                                                            FutureBuilder<
                                                                Map<String,
                                                                    dynamic>>(
                                                              future: kronikSorular(),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot<
                                                                          Map<String,
                                                                              dynamic>>
                                                                      snapshot) {
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return CircularProgressIndicator();
                                                                } else if (snapshot
                                                                    .hasError) {
                                                                  return Text(
                                                                      'Hata:${snapshot.error}');
                                                                } else {
                                                                  String
                                                                      message =
                                                                      '';
                                                                  if (snapshot
                                                                          .data !=
                                                                      null) {
                                                                    if (snapshot
                                                                        .data!
                                                                        .isEmpty) {
                                                                      message =
                                                                          'Kronik yanlış soru bulunamadı';
                                                                    } else {
                                                                      message =
                                                                          'Kronik yanlış sorular: ${snapshot.data}';
                                                                    }
                                                                  }
                                                                  return Text(
                                                                    message,
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Themes
                                                                          .cardTextColor,
                                                                      fontSize:
                                                                          Tokens
                                                                              .fontSize[2],
                                                                      fontWeight:
                                                                          Tokens
                                                                              .fontWeight[5],
                                                                    ),
                                                                  );
                                                                }
                                                              },
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
                        },
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
