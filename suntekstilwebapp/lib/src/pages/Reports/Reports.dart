import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

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
  void showModal(BuildContext context, Color backgroundColor, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomModal(
          backgroundColor: backgroundColor,
          text: text,
          child: Container(),
        );
      },
    );
  }

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
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
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
                                "LOKASYON MÜDÜRÜ",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text("LOKASYON",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "LOKASYON KODU",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(8.0),
                                color: Themes.yellowColor,
                                child: Text(
                                  "LOKASYON TİPİ",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[2]),
                                )),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "ZİYARET TİPİ",
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
                                "TARİH",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "MAİL GÖNDERİLME DURUMU",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.yellowColor,
                              child: Text(
                                "ALINAN PUAN",
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
                              ),
                            ),
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Emre Suaklier",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Mersin Forum AVM",
                                  style: TextStyle(
                                    fontWeight: Tokens.fontWeight[2],
                                  )),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "1038",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "AVM",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Görsel CheckList- Puanlı",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Çağrı Yiğit",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "28.03.2024",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gönderildi",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "95,00",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: CustomButton(
                                buttonText: 'Düzenle',
                                textColor: Themes.blueColor,
                                buttonColor: Themes.whiteColor,
                                onPressed: () {
                                  showModal(context, Themes.yellowColor,
                                      "Modal Açıldı");
                                },
                              ),
                            )
                          ]),
                        ]))),
          ],
        ),
      ),
    );
  }
}
