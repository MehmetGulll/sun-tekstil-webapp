import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';

class ActionPage extends StatefulWidget {
  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  List<dynamic> _allActions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchActions();
  }

  Future<void> _fetchActions() async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'page': _currentPage,
    };

    if (_searchController.text.isNotEmpty) {
      requestBody['searchTerm'] = _searchController.text;
    }

    if (_startDate != null) {
      requestBody['startDate'] = DateFormat('dd.MM.yyyy').format(_startDate!);
    }

    if (_endDate != null) {
      requestBody['endDate'] = DateFormat('dd.MM.yyyy').format(_endDate!);
    }

    final response = await http.post(
      Uri.parse(ApiUrls.getMyAction),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("responseData: $responseData");
      setState(() {
        _allActions = responseData['data'];
        _totalPages = responseData['count'] ~/ responseData['perPage'] +
            ((responseData['count'] % responseData['perPage'] == 0) ? 0 : 1);
      });
    } else {
      throw Exception('Failed to load actions');
    }
  }

  Future<void> _closeAction(int? id, String closingSubject) async {
    if (id == null) {
      throw ArgumentError('id must not be null.');
    }

    String? token = await TokenHelper.getToken();

    try {
      final response = await http.post(
        Uri.parse(ApiUrls.closeAction),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
        body: jsonEncode(
            {'aksiyon_id': id, 'aksiyon_kapama_konu': closingSubject}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("responseData: $responseData");
        _fetchActions();
      } else {
        throw Exception('Aksiyon kapatma işlemi başarısız oldu.');
      }
    } catch (e) {
      print('Error closing action: $e');
      throw Exception('Aksiyon kapatma işlemi sırasında bir hata oluştu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Arama yapın...',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _applyFilters,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    final selectedStartDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      _startDate = selectedStartDate;
                    });
                  },
                  child: Text(_startDate == null
                      ? 'Başlangıç Tarihi'
                      : DateFormat('dd.MM.yyyy')
                          .format(_startDate!)
                          .substring(0, 10)),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    final selectedEndDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      _endDate = selectedEndDate;
                    });
                  },
                  child: Text(_endDate == null
                      ? 'Bitiş Tarihi'
                      : DateFormat('dd.MM.yyyy')
                          .format(_endDate!)
                          .substring(0, 10)),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: _applyFilters,
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever_sharp),
                  onPressed: _clearFilters,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16.0,
                    columns: [
                      DataColumn(
                          label: Text('ID',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                        label: Text('Aksiyon Konu',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Açılış Tarihi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Bitiş Tarihi',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Süre',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Öncelik',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Oluşturan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      // DataColumn(
                      //   label: Text('Aksiyon Kapatan', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                      // ),
                      DataColumn(
                        label: Text('Mağaza Adı',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Mağaza Müdürü',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Aksiyon Sorusu',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Doğru Cevap',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Verilen Cevap',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Görsel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Kapatma Açıklaması',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('İşlemler',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                    rows: _allActions
                        .map(
                          (action) => DataRow(
                            cells: [
                              DataCell(Text(
                                (_allActions.indexOf(action) + 1).toString(),
                              )),
                              DataCell(
                                Text(action['aksiyon_konu'] ?? 'N/A'),
                              ),
                              DataCell(
                                Text(action['aksiyon_acilis_tarihi'] ?? 'N/A'),
                              ),
                              DataCell(
                                Text(action['aksiyon_bitis_tarihi'] ?? 'N/A'),
                              ),
                              DataCell(
                                Text(action['aksiyon_sure']?.toString() ??
                                    'N/A'),
                              ),
                              DataCell(
                                Text(action['aksiyon_oncelik']?.toString() ==
                                        '1'
                                    ? 'Çok Önemli'
                                    : action['aksiyon_oncelik']?.toString() ==
                                            '2'
                                        ? 'Önemli'
                                        : action['aksiyon_oncelik']
                                                    ?.toString() ==
                                                '3'
                                            ? 'Orta'
                                            : action['aksiyon_oncelik']
                                                        ?.toString() ==
                                                    '4'
                                                ? 'Az Önemli'
                                                : action['aksiyon_oncelik']
                                                            ?.toString() ==
                                                        '5'
                                                    ? 'Çok Az Önemli'
                                                    : 'N/A'),
                              ),
                              DataCell(
                                Text(action['aksiyon_olusturan_id']
                                        ?.toString() ??
                                    'N/A'),
                              ),
                              // DataCell(
                              //   Text(action['aksiyon_kapatan_id']?.toString() ??
                              //       'N/A'),
                              // ),
                              DataCell(
                                Text(action['magaza_adi'] ?? 'N/A'),
                              ),
                              DataCell(
                                Text(action['magaza_muduru'] ?? 'N/A'),
                              ),
                              DataCell(
                                Container(
                                  // width:
                                      // 200, // Set the desired maximum width here
                                  child: Text(
                                    action['aksiyon_sorusu'] ?? 'N/A',
                                    maxLines: null, // Allow unlimited lines
                                    overflow: TextOverflow
                                        .visible, // Overflow behavior
                                  ),
                                ),
                              ),

                              DataCell(
                                Text(
                                  '${action['soru_dogru_cevap'] ?? 'N/A'}',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${action['soru_verilen_cevap'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: action['soru_verilen_cevap'] ==
                                            action['soru_dogru_cevap']
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                action['aksiyon_gorsel'] != null
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.network(
                                                          action[
                                                              'aksiyon_gorsel'],
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                            'Görseli Kapat',
                                                            style: TextStyle(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  191,
                                                                  191,
                                                                  191),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: MouseRegion(
                                                        cursor:
                                                            SystemMouseCursors
                                                                .click,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                225, 79, 68),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Image.network(
                                              action['aksiyon_gorsel'],
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text('Görsel Yok'),
                              ),

                              DataCell(
                                Text(action['aksiyon_kapama_konu'] ?? 'N/A'),
                              ),
                              DataCell(
                                ButtonBar(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.mode_edit_outlined),
                                      tooltip: action["status"] == 0 ? "Aksiyon Kapatılmış!" :
                                      action['aksiyon_konu'] +
                                          " Denetimini Düzenle",
                                      onPressed: action['status'] == 0
                                          ? null
                                          : () {
                                              String actionSubject =
                                                  action['aksiyon_konu'] ??
                                                      'N/A';
                                              String closingSubject = '';

                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        'Seçilen Aksiyon Konusu: $actionSubject'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Kapatma Açıklaması',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          onChanged: (value) {
                                                            closingSubject =
                                                                value;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('İptal'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed:
                                                            action['status'] ==
                                                                    0
                                                                ? null
                                                                : () async {
                                                                    await _closeAction(
                                                                        action[
                                                                            'aksiyon_id'],
                                                                        closingSubject);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                        child: Text(
                                                            'Aksiyonu Tamamla'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                      color: action['status'] == 0
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _currentPage == 1 ? null : _previousPage,
              ),
              Text('$_currentPage/$_totalPages'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _currentPage == _totalPages ? null : _nextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _fetchActions();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
    _fetchActions();
  }

  void _previousPage() {
    setState(() {
      _currentPage--;
    });
    _fetchActions();
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchActions();
  }
}
