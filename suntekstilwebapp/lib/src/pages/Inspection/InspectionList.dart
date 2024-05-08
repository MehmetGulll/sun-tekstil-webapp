import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';

class InspectionPage extends StatefulWidget {
  @override
  _InspectionPageState createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  List<dynamic> _inspectionList = [];
  int _currentPage = 1;
  int _totalPages = 1;
  TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchInspections();
  }

  Future<void> _fetchInspections() async {
    String? token = await TokenHelper.getToken();
    // Boş searchTerm'i API isteğine ekleme
    Map<String, dynamic> requestBody = {
      'page': _currentPage,
    };
    if (_searchController.text.isNotEmpty) {
      requestBody['searchTerm'] = _searchController.text;
      requestBody['page'] = 1;
    }
    if (_startDate != null) {
      requestBody['startDate'] = DateFormat('dd.MM.yyyy').format(_startDate!);
      requestBody['page'] = 1;
    }
    if (_endDate != null) {
      requestBody['endDate'] = DateFormat('dd.MM.yyyy').format(_endDate!);
      requestBody['page'] = 1;
    }

    print("startDate: ${_startDate}");
    print("endDate: ${_endDate}");
    print("searchTerm: ${_searchController.text}");
    print("requestBody: ${requestBody}");

    final response = await http.post(
      Uri.parse(ApiUrls.getInspections),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _inspectionList = responseData['data'];
        _totalPages = responseData['count'] ~/ responseData['perPage'] +
            ((responseData['count'] % responseData['perPage'] == 0) ? 0 : 1);
      });
    } else {
      throw Exception('Failed to load inspections');
    }
  }

  void _onNextPage() {
    setState(() {
      if (_currentPage < _totalPages) {
        _currentPage++;
        _fetchInspections();
      }
    });
  }

  void _onPreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
        _fetchInspections();
      }
    });
  }

  void _applyFilters() {
    _fetchInspections();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                      : DateFormat('yyyy-MM-dd')
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
                      : DateFormat('yyyy-MM-dd')
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
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 150, // Mağaza Adı
                        child: Text(
                          'Mağaza Adı',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Şehir
                        child: Text(
                          'Şehir',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetim Tipi
                        child: Text(
                          'Denetim Tipi',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetim Tarihi
                        child: Text(
                          'Denetim Tarihi',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 130, // Tamamlanma Tarihi
                        child: Text(
                          'Tamamlanma Tarihi',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Şehir
                        child: Text(
                          'Şehir',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetçi
                        child: Text(
                          'Denetçi',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Denetim Puanı
                        child: Text(
                          'Denetim Puanı',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 155, // Durum
                        child: Text(
                          'Durum',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  rows: _inspectionList.map((inspection) {
                    return DataRow(cells: [
                      DataCell(
                        Text(
                          inspection['magaza_adi'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          '${inspection['sehir']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['denetim_tipi'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['denetim_tarihi'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['denetim_tamamlanma_tarihi'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['sehir'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['denetci'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        Text(
                          inspection['alinan_puan'].toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            // Burada duruma göre yapılacak işlemi belirtin
                          },
                          // text   width: 120
                          child: Text(
                            inspection['status'] == 0
                                ? 'Detayı Görüntüle'
                                : 'Denetimi Yap',
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _onPreviousPage,
              ),
              Text('$_currentPage / $_totalPages'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _onNextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InspectionPage(),
  ));
}
