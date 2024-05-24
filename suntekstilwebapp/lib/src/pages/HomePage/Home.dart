import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:suntekstilwebapp/src/pages/SuccessRate/SuccessRate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? userId;
  List<dynamic> lastThreeInspections = [];
  List<dynamic> stores = [];
  Map<String, dynamic> inspectionCompletionStatus = {};
  List<dynamic> frequentlyWrongQuestions = [];
  List<dynamic> getMostActionQuestion = [];
  List<dynamic> getMostActionStore = [];

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() async {
    int? fetchedUserId = await currentUserIdHelper.getCurrentUserId();
    setState(() {
      userId = fetchedUserId;
      fetchData();
    });
  }

  void fetchData() async {
    await _getLastThreeInspections();
    await _getStores();
    await _getInspectionCompletionStatus(userId!);
    await _getFrequentlyWrongQuestions();
    await _getMostActionQuestion();
    await _getMostActionStore();
  }

  Future<void> _getLastThreeInspections() async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse('${ApiUrls.getLastThreeInspections}/$userId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.body == '[]') {
      setState(() {
        lastThreeInspections = [ ];
      });
    }
    if (response.statusCode == 200) {
      setState(() {
        lastThreeInspections = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }

  Future<void> _getStores() async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse(ApiUrls.storesUrl),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        stores = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }

  Future<void> _getInspectionCompletionStatus(int intId) async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse('${ApiUrls.getInspectionCompletionStatus}/$intId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        inspectionCompletionStatus = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }

  Future<void> _getFrequentlyWrongQuestions() async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse(ApiUrls.getFrequentlyWrongQuestions),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        frequentlyWrongQuestions = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }

  Future<void> _getMostActionQuestion() async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse(ApiUrls.getMostActionQuestion),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        getMostActionQuestion = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }
  
  Future<void> _getMostActionStore() async {
    var token = await TokenHelper.getToken();
    var response = await http.get(
      Uri.parse(ApiUrls.getMostActionStore),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        getMostActionStore = jsonDecode(response.body);
      });
    } else {
      print(response.body);
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Jimmy Key Denetim Yönetim Sistemi',
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildImageBox('assets/homeImage.jpeg'),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildInspectionsBox(),
                            ),
                            Expanded(
                              flex: 3,
                              child: _buildInspectionCompletionStatusBox(),
                            ),
                          ],
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
                              child: _mostActionQuestion(),
                            ),
                            Expanded(
                              child: _mostActionStore(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildFrequentlyWrongQuestionsBox(),
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

  Widget _buildImageBox(String imagePath) {
    return Card(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

Widget _buildInspectionsBox() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 36),
              SizedBox(width: 8),
              Text(
                'En Son 3 Denetimim',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  lastThreeInspections.map((inspection) {
              String inspectionType = inspection['denetim_tipi'];
              String inspectionDate = inspection['denetim_tarihi'];
              inspectionDate = inspectionDate.split('-').reversed.join('.');
              String store = inspection['magaza'];
              String auditor = inspection['denetci'];
              String status = inspection['status'] == 0 ? 'Tamamlandı' : 'Tamamlanmadı';
              String score = inspection['alinan_puan'] == '' ? '' : inspection['alinan_puan'].toString();

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Denetim Türü: $inspectionType , Mağaza: $store , Denetçi: $auditor , Denetim Tarihi: $inspectionDate , Durum: $status , Alınan Puan: $score', style: TextStyle(fontSize: 15)), 
                  ],
                ),
              );
            }).toList() 
          ),
        ],
      ),
    ),
  );
}

//  List<dynamic> getMostActionQuestion = [];
//  {
//         "soru_id": 15,
//         "soru_adi": "Mağaza içerisinde veya depoda İş Güvenliğini tehlikeye atacak bir durum varmı?",
//         "aksiyon_sayisi": 9
//     },
Widget _mostActionQuestion(){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 36),
                SizedBox(width: 8),
                Text(
                  'En Çok Aksiyon Alan Sorular',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: getMostActionQuestion.length,
                itemBuilder: (context, index) {
                  var question = getMostActionQuestion[index];
                  return ListTile(
                    title: Text("• "+question['soru_adi']),
                    subtitle: Text(
                        ' Soru ID: ${question['soru_id']}, Aksiyon Sayısı: ${question['aksiyon_sayisi']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
}

//   List<dynamic> getMostActionStore = [];
//  {
//         "magaza_id": 3,
//         "magaza_adi": "Avcılar Cadde Mağaza",
//         "magaza_muduru": "Atakan Doğan",
//         "aksiyon_sayisi": 13
//     },

Widget _mostActionStore(){
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 36),
              SizedBox(width: 8),
              Text(
                'En Çok Aksiyon Alan Mağazalar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: getMostActionStore.length,
              itemBuilder: (context, index) {
                var store = getMostActionStore[index];
                return ListTile(
                  title: Text("• "+store['magaza_adi']),
                  subtitle: Text(
                      ' Mağaza ID: ${store['magaza_id']}, Mağaza Müdürü: ${store['magaza_muduru']}, Aksiyon Sayısı: ${store['aksiyon_sayisi']}'),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

}

  // Widget _buildActions() {
  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.assignment, size: 36),
  //               SizedBox(width: 8),
  //               Text(
  //                 'En Çok Aksiyon Alan Sorular',
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 8),
  //           Expanded(
  //             child: ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: getMostActionQuestion.length,
  //               itemBuilder: (context, index) {
  //                 var question = getMostActionQuestion[index];
  //                 return ListTile(
  //                   title: Text("• "+question['soru_adi']),
  //                   subtitle: Text(
  //                       ' Soru ID: ${question['soru_id']}, Aksiyon Sayısı: ${question['aksiyon_sayisi']}'),
  //                 );
  //               },
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.store, size: 36),
  //               SizedBox(width: 8),
  //               Text(
  //                 'En Çok Aksiyon Alan Mağazalar',
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 8),
  //           Expanded(
  //             child: ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: getMostActionStore.length,
  //               itemBuilder: (context, index) {
  //                 var store = getMostActionStore[index];
  //                 return ListTile(
  //                   title: Text("• "+store['magaza_adi']),
  //                   subtitle: Text(
  //                       ' Mağaza ID: ${store['magaza_id']}, Mağaza Müdürü: ${store['magaza_muduru']}, Aksiyon Sayısı: ${store['aksiyon_sayisi']}'),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

Widget _buildFrequentlyWrongQuestionsBox() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 36),
              SizedBox(width: 8),
              Text(
                'Kronik Hale Gelen Sorular',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: frequentlyWrongQuestions.length,
              itemBuilder: (context, index) {
                var question = frequentlyWrongQuestions[index];
                var questions = question['questions'] as List<dynamic>;
                return Column(
                  children: questions
                      .map((q) => ListTile(
                            title: Text("• "+q['soru_adi']),
                            subtitle: Text(
                                ' Soru ID: ${q['soru_id']}, Hata Sayısı: ${q['question_count']}'),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildInspectionCompletionStatusBox() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 36),
                  SizedBox(width: 8),
                  Text(
                    'ZİYARET SAYISI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${inspectionCompletionStatus['completedCount']}/${inspectionCompletionStatus['totalCount']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Icon(Icons.arrow_right , size: 36),
                  Text(
                    '${inspectionCompletionStatus['completionPercentage']}%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Ziyaret Tamamlanma Durumu',
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Tooltip(
                message: 'Başarı Oranlarını İstatistiğini Görmek İçin Tıklayınız',
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessRate(),
                      ),
                    );
                  },
                  child: Text('BAŞARI ORANLARINI GÖR'),
                ),
              ),
              
            ),
            SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Aktif Lokasyon Sayısı',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(width: 8),
                  Text(
                    stores.length.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
