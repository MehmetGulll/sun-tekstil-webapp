import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReportDetail extends StatefulWidget {
  final String reportId;
  final String inspectorRole;
  final String inspectorName;
  final String storeName;
  final String points;
  final String inspectionType;
  final String inspectionDate;
  ReportDetail(
      {Key? key,
      required this.reportId,
      required this.inspectorRole,
      required this.inspectorName,
      required this.storeName,
      required this.points,
      required this.inspectionType,
      required this.inspectionDate})
      : super(key: key);
  @override
  _ReportDetailState createState() => _ReportDetailState();
}

class _ReportDetailState extends State<ReportDetail> {
  List<Map<String, dynamic>> _reportDetail = [];

  void createExcelAndDownload(List<Map<String, dynamic>> data) {
    var excel = Excel.createExcel();

    Sheet sheetObject = excel['Sheet1'];

    sheetObject.setColumnWidth(0, 50);
    sheetObject.setColumnWidth(1, 35);
    sheetObject.setColumnWidth(2, 35);
    sheetObject.setColumnWidth(3, 35);

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
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'RaporDetayi.xlsx';
    html.document.body!.children.add(anchor);

    anchor.click();

    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void createPdfAndDownload(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    final fontData =
        await rootBundle.load('fonts/NotoSans_Condensed-Black.ttf');

    final font = pw.Font.ttf(fontData);

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Table(border: pw.TableBorder.all(width: 1.0), columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      }, children: [
        pw.TableRow(children: [
          pw.Container(
              child: pw.Text('SORU ADI', style: pw.TextStyle(font: font)),
              alignment: pw.Alignment.center),
          pw.Container(
              child: pw.Text('VERİLEN CEVAP', style: pw.TextStyle(font: font)),
              alignment: pw.Alignment.center),
          pw.Container(
              child: pw.Text('SORU PUAN', style: pw.TextStyle(font: font)),
              alignment: pw.Alignment.center),
          pw.Container(
              child: pw.Text('DOĞRU CEVAP', style: pw.TextStyle(font: font)),
              alignment: pw.Alignment.center),
        ]),
        ...data.map((item) => pw.TableRow(children: [
              pw.Container(
                  child:
                      pw.Text(item['soruAdi'], style: pw.TextStyle(font: font)),
                  alignment: pw.Alignment.center),
              pw.Container(
                  child: pw.Text(item['soruCevap'] == 0 ? 'Evet' : 'Hayır',
                      style: pw.TextStyle(font: font)),
                  alignment: pw.Alignment.center),
              pw.Container(
                  child: pw.Text(item['soruPuan'].toString(),
                      style: pw.TextStyle(font: font)),
                  alignment: pw.Alignment.center),
              pw.Container(
                  child: pw.Text(item['dogruCevap'] == 0 ? 'Evet' : 'Hayır',
                      style: pw.TextStyle(font: font)),
                  alignment: pw.Alignment.center),
            ]))
      ]);
    }));

    final Future<Uint8List> pdfDataFuture = pdf.save();

    final Uint8List pdfData = await pdfDataFuture;

    final blob = html.Blob([pdfData.buffer.asUint8List()], 'application/pdf');

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'RaporDetayi.pdf';

    anchor.click();
  }

  Future<List<Map<String, dynamic>>> getReportDetail() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.detailReport}/${int.parse(widget.reportId)}'));
      if (response.statusCode == 200) {
        _reportDetail =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        print("rapor detayları $_reportDetail");
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
      pageTitle: 'Rapor Detayları',
      body: SingleChildScrollView(
        child: FutureBuilder<List>(
          future: getReportDetail(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<TableRow> rows = snapshot.data!.map((report) {
                bool isCorrect = report['soruCevap'] == report['dogruCevap'];
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
                    decoration: BoxDecoration(
                      color: isCorrect ? Themes.greenColor : Themes.secondaryColor,
                    ),
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
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Rapor Detayı",
                        style: TextStyle(
                            fontSize: Tokens.fontSize[9],
                            fontWeight: Tokens.fontWeight[6]),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                            buttonText: 'Excel',
                            buttonColor: Themes.greenColor,
                            onPressed: () {
                              print("Excel çıktısı alındı");
                              List<Map<String, dynamic>> data =
                                  List<Map<String, dynamic>>.from(
                                      snapshot.data!);
                              createExcelAndDownload(data);
                            }),
                        SizedBox(
                          width: 20,
                        ),
                        CustomButton(
                            buttonText: 'PDF ',
                            buttonColor: Themes.secondaryColor,
                            onPressed: () {
                              print("PDF çıktısı");
                              List<Map<String, dynamic>> data =
                                  List<Map<String, dynamic>>.from(
                                      snapshot.data!);
                              createPdfAndDownload(data);
                            })
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Denetim Tipi: ${widget.inspectionType}",
                            style: TextStyle(
                                fontWeight: Tokens.fontWeight[7],
                                fontSize: Tokens.fontSize[5]),
                          ),
                          Text("Denetim Lokasyon: ${widget.storeName}",
                              style: TextStyle(
                                  fontWeight: Tokens.fontWeight[7],
                                  fontSize: Tokens.fontSize[5])),
                          Text("Denetim Tarihi: ${widget.inspectionDate}",
                              style: TextStyle(
                                  fontWeight: Tokens.fontWeight[7],
                                  fontSize: Tokens.fontSize[5])),
                          Text("Denetleyen: ${widget.inspectorName}",
                              style: TextStyle(
                                  fontWeight: Tokens.fontWeight[7],
                                  fontSize: Tokens.fontSize[5])),
                          Text("Denetim Id: ${widget.reportId}",
                              style: TextStyle(
                                  fontWeight: Tokens.fontWeight[7],
                                  fontSize: Tokens.fontSize[5])),
                          Text("Alınan Puan: ${widget.points}",
                              style: TextStyle(
                                  fontWeight: Tokens.fontWeight[7],
                                  fontSize: Tokens.fontSize[5])),
                        ],
                      ),
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
                        },
                        border: TableBorder.all(color: Themes.blackColor),
                        children: [
                          TableRow(children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.cardBackgroundColor,
                              child: Text(
                                "SORU ADI",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.cardBackgroundColor,
                              child: Text(
                                "VERİLEN CEVAP",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.cardBackgroundColor,
                              child: Text(
                                "SORU PUAN",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              color: Themes.cardBackgroundColor,
                              child: Text(
                                "DOĞRU CEVAP",
                                style:
                                    TextStyle(fontWeight: Tokens.fontWeight[2]),
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
