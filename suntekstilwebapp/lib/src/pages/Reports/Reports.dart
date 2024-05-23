import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/pages/ReportDetail/ReportDetail.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';

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

  Future<void> deleteReport(int id) async {
    final response =
        await http.delete(Uri.parse('${ApiUrls.deleteReport}/$id'));
    if (response.statusCode == 200) {
      print("Rapor başarıyla silindi");
      setState(() {
        _reports.removeWhere((report) => report['inspectionId'] == id);
      });
    } else {
      print("Bir hata oluştu");
    }
  }

  Future<void> updateReport(
      BuildContext context, int id, Map<String, dynamic> report) async {
    var currentStatus = report['status'];
    var newStatus = currentStatus == 0 ? 1 : 0;
    report['status'] = newStatus;
    print("status değeeri");
    print(report['status']);
    print("id değeri");
    print(report['inspectionId']);
    String? token = await TokenHelper.getToken();

    final response = await http.put(
      Uri.parse(ApiUrls.updateReport),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, String>{
        'inspectionId': report['inspectionId'].toString(),
        'status': newStatus.toString()
      }),
    );
    if (response.statusCode == 200) {
      print("Rapor başarıyla güncellendi");
      setState(() {
        var updatedReport =
            _reports.firstWhere((r) => r['inspectionId'] == r['inspectionId']);
        updatedReport['status'] = newStatus;
      });
    } else {
      print("Bir hata oluştu");
    }
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
  void showModal(
      BuildContext context, Color backgroundColor, String text, Map report) {
    Map<String, int> items = {
      'Bölge Müdürü Haftalık Kontrol': 1,
      'Bölge Müdürü Aylık Kontrol': 2,
      'Görsel Denetim': 3,
      'Mağaza Denetim': 4,
    };
    inspectionTypeController.text = report['inspectionTypeId'].toString();
    storeNameController.text = report['storeId'].toString();
    inspectionRoleController.text = report['inspectorRole'].toString();
    inspectionerNameController.text = report['inspectorName'].toString();
    inspectionPointController.text = report['pointsReceived'].toString();
    inspectionDateController.text = report['inspectionDate'].toString();
    inspectionCompletionDateController.text =
        report['inspectionCompletionDate'].toString();
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
                    "Rapor Düzenle",
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
                      selectedItem: report['status'] == 1 ? 'Aktif' : 'Pasif',
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
                      textColor: Themes.blackColor,
                      buttonColor: Themes.dividerColor,
                      onPressed: () async {
                        await updateReport(context, report['inspectionId'],
                            Map<String, dynamic>.from(report));
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  String? _chosenInspectorType;
  String? _chosenInspectorRole;
  String? _chosenInspectorName;
  String? _chosenLocationType;
  String? _chosenAuditor;
  String? _chosenVisitType;
  String? _chosenCenterTeam;

  List<String> _inspectorType = [];
  List<String> _inspectorRole = [];
  List<String> _inspectorName = [];
  List<String> _locationTypeList = [
    'Location Type 1',
    'Location Type 2',
    'Location Type 3'
  ];
  List<String> _auditorList = ['Auditor 1', 'Auditor 2', 'Auditor 3'];
  List<String> _visitTypeList = ['VisitType 1', 'VisitType 2', 'VisitType 3'];
  List<String> _centerTeamList = ['Team 1', 'Team 2', 'Team 3'];
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
                      report['inspectionTypeId'],
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['storeId'],
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectorRole'],
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectorName'],
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['pointsReceived'].toString(),
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectionDate'],
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['inspectionCompletionDate'] ?? 'BELİRSİZ',
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
                        showModal(context, Themes.whiteColor, "", report);
                      },
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
                      textColor:Themes.blackColor,
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
                            "DÜZENLE",
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
