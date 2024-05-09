import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:suntekstilwebapp/src/presentation/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:suntekstilwebapp/src/presentation/indicator.dart';
import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/Charts/PieCharts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  Map<int, double> averageScores = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchAverageScores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: 1.3,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            if (touchedIndex != -1) {
                              setState(() {
                                touchedIndex = -1;
                              });
                            }
                            return;
                          }
                        }),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 100,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Indicator(
                        color: AppColors.contentColorBlue,
                        text: 'Mağaza Denetim',
                        isSquare: true,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: AppColors.contentColorYellow,
                      text: 'Görsel Denetim',
                      isSquare: true,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: AppColors.contentColorPurple,
                      text: 'Bölge Müdürü Haftalık Denetim',
                      isSquare: true,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Indicator(
                      color: AppColors.contentColorGreen,
                      text: 'Bölge Müdürü Aylık Denetim',
                      isSquare: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> fetchAverageScores() async {
    final response = await http
        .get(Uri.parse("${ApiUrls.getAverageScoresByInspectionType}"));
    var data = jsonDecode(response.body);
    data.forEach((item) {
      averageScores[item['inspectionTypeId']] = item['averageScore'];
    });
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.contentColorBlue,
            value: averageScores[4] ?? 0,
            title: '${averageScores[4] ?? 0}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.contentColorYellow,
            value: averageScores[3] ?? 0,
            title: '${averageScores[3] ?? 0}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: AppColors.contentColorPurple,
            value: averageScores[1] ?? 0,
            title: '${averageScores[1] ?? 0}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: AppColors.contentColorGreen,
            value: averageScores[2] ?? 0,
            title: '${averageScores[2] ?? 0}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
