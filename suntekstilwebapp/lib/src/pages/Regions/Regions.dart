import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Modal/Modal.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class Regions extends StatefulWidget {
  @override
  _RegionsState createState() => _RegionsState();
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

class _RegionsState extends State<Regions> {
  String? _chosenCountry;
  String? _chosenOperation;
  String? _chosenRegion;
  String? _chosenLocation;
  String? _chosenLocationType;

  List<String> _countryList = ['Country 1', 'Country 2', 'Country 3'];
  List<String> _operationList = ['Operation 1', 'Operation 2', 'Operation 3'];
  List<String> _regionList = ['Region 1', 'Region 2', 'Region 3'];
  List<String> _locationList = ['Location 1', 'Location 2', 'Location 3'];
  List<String> _locationTypeList = [
    'Location Type 1',
    'Location Type 2',
    'Location Type 3'
  ];
  void showModal(BuildContext context, Color backgroundColor, String text) {
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
                    "Bölge Düzenle",
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
                controller: TextEditingController(),
                hintText: 'Lokasyon',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Lokasyon Tipi',
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: 20,
              ),
              CustomInput(
                controller: TextEditingController(),
                hintText: 'Şehir',
                keyboardType: TextInputType.text,
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
                        print("Silindi");
                        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: SingleChildScrollView(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildRow("Ülke", _countryList,
            (value) => setState(() => _chosenCountry = value)),
        SizedBox(height: 10),
        buildRow("Operasyon", _operationList,
            (value) => setState(() => _chosenOperation = value)),
        SizedBox(height: 10),
        buildRow("Lokasyon", _locationList,
            (value) => setState(() => _chosenLocation = value)),
        SizedBox(height: 10),
        buildRow("Bölge", _regionList,
            (value) => setState(() => _chosenRegion = value)),
        SizedBox(height: 10),
        buildRow("Lokasyon Tipi", _locationTypeList,
            (value) => setState(() => _chosenLocationType = value)),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 350),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CustomButton(
                  buttonText: "Ara",
                  onPressed: () {
                    print("Butona basıldı");
                  },
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: CustomButton(
                  buttonText: "Lokasyon Ekle",
                  onPressed: () {
                    Navigator.pushNamed(context, '/addLocation');
                  },
                ),
              )
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.all(30),
            child: Text(
              "Bölgeler",
              style: TextStyle(
                  fontSize: Tokens.fontSize[9],
                  fontWeight: Tokens.fontWeight[6]),
            )),
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
                            "LOKASYON",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text("LOKASYON TİPİ",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "ŞEHİR",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
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
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İSTANBUL MALTEPE PARK",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text("AVM",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İstanbul ",
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
                              showModal(context, Themes.whiteColor, "");
                            },
                          ),
                        )
                      ]),
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İSTANBUL MALTEPE PARK",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text("AVM",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İstanbul ",
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
                              showModal(
                                  context, Themes.yellowColor, "Modal Açıldı");
                            },
                          ),
                        )
                      ]),
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İSTANBUL MALTEPE PARK",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text("AVM",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İstanbul ",
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
                              showModal(
                                  context, Themes.yellowColor, "Modal Açıldı");
                            },
                          ),
                        )
                      ]),
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İSTANBUL MALTEPE PARK",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text("AVM",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İstanbul ",
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
                              showModal(
                                  context, Themes.yellowColor, "Modal Açıldı");
                            },
                          ),
                        )
                      ]),
                      TableRow(children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İSTANBUL MALTEPE PARK",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text("AVM",
                              style: TextStyle(
                                fontWeight: Tokens.fontWeight[2],
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "İstanbul ",
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
                              showModal(
                                  context, Themes.yellowColor, "Modal Açıldı");
                            },
                          ),
                        )
                      ]),
                    ]))),
      ],
    )));
  }
}
