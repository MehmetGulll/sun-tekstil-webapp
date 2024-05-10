import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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

  void _performInspection(Map<String, dynamic> inspection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionScreen(inspection: inspection),
      ),
    );
  }

  void _viewDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen()),
    );
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
                            inspection['status'] == 0
                                ? _viewDetail()
                                : _performInspection(inspection);
                          },
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

class InspectionScreen extends StatefulWidget {
  final Map<String, dynamic> inspection;

  InspectionScreen({required this.inspection});

  @override
  _InspectionScreenState createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  List<dynamic> _inspectionQuestions = [];
  Map<int, bool> _actionVisibilityMap = {};
  Map<int, Map<String, dynamic>> _actionMap = {};

  @override
  void initState() {
    super.initState();
    _getAllInspectionQuestions();
  }

  Future<void> _getAllInspectionQuestions() async {
    final denetimTipId = widget.inspection['denetim_tip_id'];
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.getAllInspectionQuestionsByType),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, dynamic>{
        'denetim_tip_id': denetimTipId,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _inspectionQuestions = responseData['data'];
        _actionVisibilityMap = Map.fromIterable(_inspectionQuestions,
            key: (question) => question['soru_id'], value: (_) => false);
      });
    } else {
      throw Exception('Failed to load inspection questions');
    }
  }

  void _answerInspection(Map<String, dynamic> inspection) async {
    List<Map<String, dynamic>> requestBodyList = [];
    _inspectionQuestions.forEach((question) {
      final int soruId = question['soru_id'];
      final int cevap = question['soru_cevap'];

      Map<String, dynamic> answer = {
        'soru_id': soruId,
        'cevap': cevap,
      };

      if (_actionMap.containsKey(soruId)) {
        answer['aksiyon'] = [_actionMap[soruId]];
      }

      requestBodyList.add(answer);
    });

    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.answerInspection),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode({
        "denetim_id": inspection['denetim_id'],
        "cevaplar": requestBodyList,
      }),
    );

    if (response.statusCode == 200) {
      print('Inspection answered successfully: ${response.body}');
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to answer inspection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seçili Denetim Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Denetim Tipi: ${widget.inspection['denetim_tipi']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Mağaza Adı: ${widget.inspection['magaza_adi']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Sorular:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _inspectionQuestions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(
                      _inspectionQuestions[index], index + 1);
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _answerInspection(widget.inspection);
              },
              child: Text('Denetimi Tamamla'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionNumber) {
    final int soruId = question['soru_id'];
    final bool isActionVisible = _actionVisibilityMap[soruId] ?? false;

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$questionNumber) ${question['soru_adi']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: question['soru_cevap'],
                  onChanged: (value) {
                    setState(() {
                      question['soru_cevap'] = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Evet'),
                    ),
                    DropdownMenuItem(
                      value: 0,
                      child: Text('Hayır'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _actionVisibilityMap[soruId] =
                          !_actionVisibilityMap[soruId]!;
                    });
                  },
                  child: Text('Aksiyon Oluştur'),
                ),
              ],
            ),
            if (isActionVisible) _buildActionAccordion(soruId),
          ],
        ),
      ),
    );
  }

  String _filePath = '';

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        List<int> bytes = result.files.first.bytes!;
        _filePath = result.files.first.name!;
        print("result is: $result");
        print("result files first bytes : ${result.files.first.bytes}");
        print("_filePath: $_filePath");
      });
    }
  }

  Widget _buildActionAccordion(int soruId) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksiyon Bilgileri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Aksiyon Konusu',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _actionMap[soruId] ??= {};
                      _actionMap[soruId]!['aksiyon_konu'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8.0),
              Flexible(
                child: DropdownButtonFormField<int>(
                  onChanged: (value) {
                    setState(() {
                      _actionMap[soruId] ??= {};
                      _actionMap[soruId]!['aksiyon_sure'] = value;
                    });
                  },
                  items: List.generate(
                    51,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text('$index Gün'),
                    ),
                  ).where((item) => item.value != 0).toList(),
                  decoration: InputDecoration(
                    labelText: 'Aktivasyon Süresi',
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Flexible(
                child: DropdownButtonFormField<int>(
                  onChanged: (value) {
                    setState(() {
                      _actionMap[soruId] ??= {};
                      _actionMap[soruId]!['aksiyon_oncelik'] = value;
                    });
                  },
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(
                          '${index + 1 == 1 ? 'Çok Önemli' : index + 1 == 2 ? 'Önemli' : index + 1 == 3 ? 'Orta' : index + 1 == 4 ? 'Az Önemli' : index + 1 == 5 ? 'Çok Az Önemli' : '-'}'),
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Öncelik',
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              // Resim ekleme işlevi ve eklenen resmi gösterme
              ElevatedButton(
                onPressed: () {
                  _openFilePicker();
                },
                child: Text('Dosya Seç'),
              ),
              SizedBox(height: 20),
              Text(
                'Dosya Yolu:',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                _filePath,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

// DETAY EKRANI
class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Denetim Detay Sayfası'),
      ),
      body: Center(
        child: Text('DENETİM İLE İLGİLİ DETAY BİLGİLER GELECEK'),
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
