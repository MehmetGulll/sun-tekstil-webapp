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

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

Widget buildRow(
    String label, List<String> items, ValueChanged<String?> onChanged) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(label),
            flex: 1,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomDropdown(
                items: items,
                onChanged: onChanged,
              ),
              flex: 2)
        ],
      ));
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

  Future<List<Map<String, dynamic>>> _getReports() async {
    var url = Uri.parse(ApiUrls.reportsUrl);
    var data = await http.get(url);

    var jsonData = json.decode(data.body) as List;
    print(jsonData);
    _reports = jsonData.map((item) => item as Map<String, dynamic>).toList();
    return _reports;
  }
  Future<void>deleteReport(int id) async{
    final response = await http.delete(Uri.parse('${ApiUrls.deleteReport}/$id'));
    if(response.statusCode == 200){
      print("Rapor başarıyla silindi");
      setState(() {
        _reports.removeWhere((report) => report['inspectionId'] == id);
      });
    }
    else{
      print("Bir hata oluştu");
    }
  }

  List<Map<String, dynamic>> _reports = [];
  void showModal(
      BuildContext context, Color backgroundColor, String text, Map report) {
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
                controller: inspectionTypeController,
                hintText: 'Denetim Tipi',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: storeNameController,
                hintText: 'Mağaza Adı',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: inspectionRoleController,
                hintText: 'Denetimci Rol',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: inspectionerNameController,
                hintText: 'Denetçi',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: inspectionPointController,
                hintText: 'Puan',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: inspectionDateController,
                hintText: 'Denetim Tarihi',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: inspectionCompletionDateController,
                hintText: 'Denetim Tamamlanma Tarihi',
                keyboardType: TextInputType.name,
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
                         if (report.containsKey('inspectionId') &&
                            report['inspectionId'] != null) {
                          print(report['inspectionId']);
                          deleteReport(report['inspectionId']);
                          print("Silindi");
                          Navigator.of(context).pop();
                        } else {
                          print("Mağaza id'si null veya bulunamadı");
                        }
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

  String? _chosenOperation;
  String? _chosenRegion;
  String? _chosenLocation;
  String? _chosenLocationType;
  String? _chosenAuditor;
  String? _chosenVisitType;
  String? _chosenCenterTeam;

  List<String> _operationList = ['Operation 1', 'Operation 2', 'Operation 3'];
  List<String> _regionList = ['Region 1', 'Region 2', 'Region 3'];
  List<String> _locationList = ['Location 1', 'Location 2', 'Location 3'];
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
        child: Column(
          children: [
            Text(
              "Raporlar",
              style: TextStyle(
                  fontSize: Tokens.fontSize[9],
                  fontWeight: Tokens.fontWeight[6]),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Text('Başlangıç Tarihi:'),
                SizedBox(width: 8),
                Text("${_startDate.toLocal()}".split(' ')[0]),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text('Seç'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Text('Bitiş Tarihi:'),
                SizedBox(width: 8),
                Text("${_endDate.toLocal()}".split(' ')[0]),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text('Seç'),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            buildRow("Operasyonlar", _operationList,
                (value) => setState(() => _chosenOperation = value)),
            SizedBox(height: 10),
            buildRow("Lokasyon", _locationList,
                (value) => setState(() => _chosenLocation = value)),
            SizedBox(height: 10),
            buildRow("Lokasyon Tipi", _locationTypeList,
                (value) => setState(() => _chosenLocationType = value)),
            SizedBox(height: 10),
            buildRow("Denetçi", _auditorList,
                (value) => setState(() => _chosenAuditor = value)),
            SizedBox(height: 10),
            buildRow("Ziyaret Tipi", _visitTypeList,
                (value) => setState(() => _chosenVisitType = value)),
            SizedBox(
              height: 10,
            ),
            buildRow("Merkez Ekibi", _centerTeamList,
                (value) => setState(() => _chosenCenterTeam = value)),
            SizedBox(height: 10),
            CustomButton(
                buttonText: "Filtreleme",
                onPressed: () {
                  print("Filtrelendi");
                }),
            Padding(
              padding: EdgeInsets.all(20),
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
                            report['inspectionCompletionDate'],
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
                      ]);
                    }).toList();

                    return Table(
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
                            color: Themes.yellowColor,
                            child: Text(
                              "DENETİM TİPİ",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text("MAĞAZA ADI",
                                style: TextStyle(
                                  fontWeight: Tokens.fontWeight[2],
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text(
                              "DENETİMCİ ROLÜ",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text(
                              "DENETÇİ",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text(
                              "PUAN",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text(
                              "DENETİM TARİHİ",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            color: Themes.yellowColor,
                            child: Text(
                              "DENETİM TAMAMLANMA GÜNÜ",
                              style:
                                  TextStyle(fontWeight: Tokens.fontWeight[2]),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "DÜZENLE",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ))
                        ]),
                        ...rows,
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
