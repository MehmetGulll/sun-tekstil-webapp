import 'package:suntekstilwebapp/src/presentation/app_resources.dart';
import 'package:suntekstilwebapp/src/extension/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Report>> fetchReports(int inspectionTypeId) async {
  final response = await http.get(
      Uri.parse('${ApiUrls.getReportsByInspectionType}/$inspectionTypeId'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print("Responsedata: ${response.body}");
    List<Report> reports =
        jsonResponse.map((item) => Report.fromJson(item)).toList();

    reports = normalizeReports(reports);

    return reports;
  } else {
    throw Exception('Failed to load reports from API');
  }
}

List<Report> normalizeReports(List<Report> reports) {
  double maxPoints = reports.fold(
      0.0,
      (prev, report) =>
          report.averagePoints! > prev ? report.averagePoints! : prev);

  if (maxPoints > 100) {
    reports = reports.map((report) {
      double normalizedPoints = (report.averagePoints! / maxPoints) * 100;
      return Report(
          regionName: report.regionName, averagePoints: normalizedPoints);
    }).toList();
  }

  return reports;
}

class Report {
  final String? regionName;
  final double? averagePoints;

  Report({this.regionName, this.averagePoints});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      regionName: json['inspectionId'],
      averagePoints: (json['inspectionTypeId'] as num?)?.toDouble(),
    );
  }
}

class _BarChart extends StatelessWidget {
  _BarChart({Key? key, required this.reports}) : super(key: key);

  final List<Report> reports;
  final List<String> regions = [
    'Ege Bölgesi',
    'İstanbul Asya Bölgesi',
    'İstanbul Avrupa Bölgesi',
    'Akdeniz Bölgesi',
    'Karadeniz Bölgesi',
    'İç Anadolu Bölgesi'
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.contentColorCyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Ege';
        break;
      case 1:
        text = 'İstanbul Asya';
        break;
      case 2:
        text = 'İstanbul Avrupa';
        break;
      case 3:
        text = 'Akdeniz';
        break;
      case 4:
        text = 'Karadeniz';
        break;
      case 5:
        text = 'İç Anadolu';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          AppColors.contentColorBlue.darken(20),
          AppColors.contentColorCyan,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups {
    return List.generate(6, (index) {
      final report = reports.firstWhere(
          (report) => report.regionName == regions[index],
          orElse: () => Report(
              regionName: regions[index],
              averagePoints:
                  0.0)); // // orElse içinde döndürülen Report nesnesinde averagePoints'i 0.0 olarak ayarladım
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: report.averagePoints ?? 0,
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
}

class BarChartSample3 extends StatelessWidget {
  final String? inspectionTypeId;
  BarChartSample3({this.inspectionTypeId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Report>>(
      future: fetchReports(int.parse(inspectionTypeId ?? '4')),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AspectRatio(
            aspectRatio: 1.6,
            child: _BarChart(reports: snapshot.data!),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}
