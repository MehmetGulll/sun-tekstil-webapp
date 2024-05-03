import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html';

class ReportDetail extends StatefulWidget {
  final String reportId;
  ReportDetail({Key? key, required this.reportId}) : super(key: key);
  @override
  _ReportDetailState createState() => _ReportDetailState();
}

class _ReportDetailState extends State<ReportDetail> {
  List<Map<String, dynamic>> _reportDetail = [];

  void createExcelAndDownload(List<Map<String, dynamic>> data) {
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['Sheet1'];

    sheetObject.cell(CellIndex.indexByString("A1")).value =
        TextCellValue('SORU ADI');
    sheetObject.cell(CellIndex.indexByString("B1")).value =
        TextCellValue('VERİLEN CEVAP');
    sheetObject.cell(CellIndex.indexByString("C1")).value =
        TextCellValue('SORU PUAN');
    sheetObject.cell(CellIndex.indexByString("D1")).value =
        TextCellValue('DOĞRU CEVAP');

    for (int i = 0; i < data.length; i++) {
      sheetObject.cell(CellIndex.indexByString('A${i + 2}')).value =
          TextCellValue(data[i]['soruAdi']);
      sheetObject.cell(CellIndex.indexByString('B${i + 2}')).value =
          TextCellValue(data[i]['soruCevap'] == 0 ? 'Evet' : 'Hayır');
      sheetObject.cell(CellIndex.indexByString('C${i + 2}')).value =
          TextCellValue(data[i]['soruPuan'].toString());
      sheetObject.cell(CellIndex.indexByString('D${i + 2}')).value =
          TextCellValue(data[i]['dogruCevap'] == 0 ? 'Evet' : 'Hayır');
    }

    var bytes = excel.encode();
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = document.createElement('a') as AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'RaporDetayi.xlsx';
    document.body!.children.add(anchor);

    anchor.click();

    document.body!.children.remove(anchor);
    Url.revokeObjectUrl(url);
  }

  Future<List<Map<String, dynamic>>> getReportDetail() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.detailReport}/${int.parse(widget.reportId)}'));
      if (response.statusCode == 200) {
        _reportDetail =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        return _reportDetail;
      } else {
        throw Exception("Failed load report detail");
      }
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<List>(
          future: getReportDetail(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<TableRow> rows = snapshot.data!.map((report) {
                return TableRow(children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['soruAdi'].toString(),
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['soruCevap'] == 0 ? 'Evet' : 'Hayır',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['soruPuan'].toString(),
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      report['dogruCevap'] == 0 ? 'Evet' : 'Hayır',
                      style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                    ),
                  ),
                ]);
              }).toList();
              return Column(children: [
                Text(
                  "Rapor Detayı",
                  style: TextStyle(
                      fontSize: Tokens.fontSize[9],
                      fontWeight: Tokens.fontWeight[6]),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                        buttonText: 'Excel Çıktısı',
                        buttonColor: Themes.greenColor,
                        onPressed: () {
                          print("Excel çıktısı alındı");
                          List<Map<String, dynamic>> data =
                              List<Map<String, dynamic>>.from(snapshot.data!);
                          createExcelAndDownload(data);
                        }),
                    SizedBox(
                      width: 20,
                    ),
                    CustomButton(
                        buttonText: 'PDF Çıktısı',
                        buttonColor: Themes.secondaryColor,
                        onPressed: () {
                          print("PDF çıktısı");
                        })
                  ],
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Table(
                    defaultColumnWidth: FlexColumnWidth(1),
                    columnWidths: {
                      0: FlexColumnWidth(2),
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
                            "SORU ADI",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "VERİLEN CEVAP",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "SORU PUAN",
                            style: TextStyle(fontWeight: Tokens.fontWeight[2]),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          color: Themes.yellowColor,
                          child: Text(
                            "DOĞRU CEVAP",
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
