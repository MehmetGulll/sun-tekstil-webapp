import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/pages/ReportDetail/ReportDetail.dart';
import 'package:toastification/toastification.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

Widget buildRow(List<String> items, ValueChanged<String?> onChanged) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: CustomDropdown(
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _ReportsState extends State<Reports> {
  final TextEditingController inspectionTypeController =
      TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController inspectionRoleController =
      TextEditingController();
  final TextEditingController inspectionerNameController =
      TextEditingController();
  final TextEditingController inspectionPointController =
      TextEditingController();
  final TextEditingController inspectionDateController =
      TextEditingController();
  final TextEditingController inspectionCompletionDateController =
      TextEditingController();

  bool isFiltered = false;

  Map<String, String> inspectionTypes = {
    'Görsel Denetim': '3',
    'Mağaza Denetim': '4'
  };
  Future<List<Map<String, dynamic>>> _getReports() async {
    if (!isFiltered) {
      var url = Uri.parse(ApiUrls.reportsUrl);
      var data = await http.get(url);

      var jsonData = json.decode(data.body) as List;
      print(jsonData);
      _reports = jsonData.map((item) => item as Map<String, dynamic>).toList();
      _inspectorType = _reports
          .map((report) => report['inspectionTypeId'].toString())
          .toSet()
          .toList();
      _inspectorName = _reports
          .map((report) => report['inspectorName'].toString())
          .toSet()
          .toList();
      _inspectorRole = _reports
          .map((report) => report['inspectorRole'].toString())
          .toSet()
          .toList();
    }
    return _reports;
  }


  

  Future<void> filteredReports() async {
    String startDate =
        '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
    String endDate =
        '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';

    print(_chosenInspectorType);
    print(_chosenInspectorRole);
    print(startDate);
    print(endDate);

    String url =
        '${ApiUrls.filteredReport}?inspectionDate=$startDate&inspectionCompletionDate=$endDate';

    if (_chosenInspectorType != null) {
      String? inspectionTypeId = inspectionTypes[_chosenInspectorType];
      print(inspectionTypeId);
      url += '&inspectionTypeId=$inspectionTypeId';
    }

    if (_chosenInspectorRole != null) {
      url += '&inspectorRole=$_chosenInspectorRole';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        toastification.show(
          context: context,
          title: Text('Başarılı'),
          description: Text('Filtreleme Başarılı.'),
          icon: const Icon(Icons.check),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true,
        );
        var jsonData = json.decode(response.body) as List;
        setState(() {
          _reports.clear();
          _reports =
              jsonData.map((item) => item as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  List<Map<String, dynamic>> _reports = [];
 

  String? _chosenInspectorType;
  String? _chosenInspectorRole;


  List<String> _inspectorType = [];
  List<String> _inspectorRole = [];
  List<String> _inspectorName = [];


  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate))
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Raporlar',
      body: SingleChildScrollView(
        child: FutureBuilder<List>(
          future: _getReports(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<TableRow> rows = snapshot.data!.map((report) {
                return TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectionTypeId'] ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['storeId'] ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectorRole'] ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectorName'] ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['pointsReceived'].toString() ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectionDate'] ?? 'N/A',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectionCompletionDate']?? 'N/A',

                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: CustomButton(
                      buttonText: 'Detay',
                      textColor: Themes.blueColor,
                      buttonColor: Themes.whiteColor,
                      onPressed: () {
                        print("Detay");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetail(
                                reportId: report['inspectionId'].toString(),
                                inspectorRole:
                                    report['inspectorRole'].toString(),
                                inspectorName:
                                    report['inspectorName'].toString(),
                                storeName: report['storeId'].toString(),
                                points: report['pointsReceived'].toString(),
                                inspectionType:
                                    report['inspectionTypeId'].toString(),
                                inspectionDate:
                                    report['inspectionDate'].toString()),
                          ),
                        );
                      },
                    ),
                  ),
                ]);
              }).toList();
              return Column(children: [
                Text(
                  "Raporlar",
                  style: TextStyle(
                      fontSize: Tokens.fontSize[9],
                      fontWeight: Tokens.fontWeight[6]),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildRow(
                          _inspectorType,
                          (value) =>
                              setState(() => _chosenInspectorType = value),
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectDate(context, true),
                            child: Text('Denetim Başlangıç Tarihi'),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _selectDate(context, false),
                            child: Text('Denetim Tamamlanma Tarihi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      buttonText: "Filtrele",
                      textColor: Themes.blackColor,
                      buttonColor: Themes.cardBackgroundColor,
                      onPressed: () async {
                        if (_startDate != null && _endDate != null) {
                          print("Filtrelendi");
                          isFiltered = true;
                          await filteredReports();
                        } else if (_startDate == null) {
                          String errorMessage = "Başlangıç tarihi seçiniz!";
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                errorMessage: errorMessage,
                                errorIcon: Icons.person_off,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        } else if (_endDate == null) {
                          String errorMessage = "Bitiş tarihi seçiniz!";
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                errorMessage: errorMessage,
                                errorIcon: Icons.person_off,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        } else {
                          print("Tarihleri seçiniz lütfen");
                        }
                      },
                    ),
                    SizedBox(width: 20),
                    CustomButton(
                      buttonText: 'Filtreleri Sil',
                      buttonColor: Themes.secondaryColor,
                      onPressed: () async {
                        print("Filtreler kaldırıldı");
                        toastification.show(
                          context: context,
                          title: Text('Başarılı'),
                          description: Text('Filtreler Temizlendi!.'),
                          icon: const Icon(Icons.check),
                          type: ToastificationType.success,
                          style: ToastificationStyle.flatColored,
                          autoCloseDuration: const Duration(seconds: 3),
                          showProgressBar: true,
                          pauseOnHover: true,
                          dragToClose: true,
                          applyBlurEffect: true,
                        );
                        isFiltered = false;
                        await _getReports();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Table(
                    defaultColumnWidth: FlexColumnWidth(1),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(1),
                      6: FlexColumnWidth(2),
                      7: FlexColumnWidth(1)
                    },
                    border: TableBorder.all(color: Themes.blackColor),
                    children: [
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DENETİM TİPİ",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "MAĞAZA ADI",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DENETİMCİ ROLÜ",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DENETÇİ",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "PUAN",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DENETİM TARİHİ",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DENETİM TAMAMLANMA GÜNÜ",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                      
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.cardBackgroundColor,
                          child: Text(
                            "DETAY GÖR",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                      ]),
                      ...rows,
                    ],
                  ),
                ),
              ]);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
