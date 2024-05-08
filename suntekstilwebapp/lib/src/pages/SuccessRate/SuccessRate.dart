import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Charts/PieCharts.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Charts/BarCharts.dart';
import 'package:suntekstilwebapp/src/components/Charts/PieCharts.dart';

class SuccessRate extends StatefulWidget {
  @override
  _SuccessRateState createState() => _SuccessRateState();
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

class _SuccessRateState extends State<SuccessRate> {
// Map<String, String> inspectionTypes = {
//     'Görsel Denetim': '3',
//     'Mağaza Denetim': '4'
//   };
  List<String> inspectionTypes = ['Görsel Denetim', 'Mağaza Denetim'];
  String? _chosenInspectorType;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          buildRow("DENETİM TİPİ", inspectionTypes,
              (value) => setState(() => _chosenInspectorType = value)),
          Row(
            children: [
              Expanded(child: PieChartSample2()),
              SizedBox(width: 20,),
              Expanded( child: BarChartSample3())
            ],
          )
        ],
      ),
    ));
  }
}
