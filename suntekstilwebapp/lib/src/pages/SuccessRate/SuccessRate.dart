import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/components/Charts/PieCharts.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Charts/BarCharts.dart';
import 'package:suntekstilwebapp/src/components/Charts/PieCharts.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:provider/provider.dart';

class SuccessRate extends StatefulWidget {
  @override
  _SuccessRateState createState() => _SuccessRateState();
}
Widget buildColumn(BuildContext context, String label, List<String> items,
    ValueChanged<String?> onChanged, Map<String, String> inspectionTypes) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Tokens.fontSize[4]),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: CustomDropdown(
              selectedItem: 'Mağaza Denetim',
            items: items,
            onChanged: (value) {
              String? numericValue = inspectionTypes[value];
              Provider.of<InspectionTypeId>(context, listen: false)
                  .inspectionTypeId = numericValue;
            },
          
          ),
        ),
      ],
    ),
  );
}



class _SuccessRateState extends State<SuccessRate> {
  Map<String, String> inspectionTypes = {
    'Bölge Müdürü Aylık Denetim': '1',
    'Bölge Müdürü Haftalık Denetim': '2',
    'Görsel Denetim': '3',
    'Mağaza Denetim': '4'
  };
  String? _chosenInspectorType;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Başarı Oranları',
        body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Themes.greyColor, width: 1),
                            color: Themes.cardBackgroundColor,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text("Denetim Başarı Oranları",
                                  style: TextStyle(
                                      fontWeight: Tokens.fontWeight[7],
                                      fontSize: Tokens.fontSize[7])),
                              SizedBox(
                                height: 30,
                              ),
                              PieChartSample2()
                            ],
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Themes.greyColor, width: 1),
                          color: Themes.cardBackgroundColor,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text("Bölgelere Göre Başarı Oranları",
                                style: TextStyle(
                                    fontWeight: Tokens.fontWeight[7],
                                    fontSize: Tokens.fontSize[7])),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: buildColumn(
                                context,
                                "DENETİM TİPİ",
                                inspectionTypes.keys.toList(),
                                (value) => setState(
                                    () => _chosenInspectorType = value), inspectionTypes
                              ),
                            ),
                            Consumer<InspectionTypeId>(
                              builder: (context, inspectionTypeId, child) {
                                return BarChartSample3(
                                    inspectionTypeId:
                                        inspectionTypeId.inspectionTypeId);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    ));
  }
}
