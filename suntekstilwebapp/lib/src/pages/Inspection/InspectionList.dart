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
import 'dart:typed_data';

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
  List<dynamic> _denetimTipiList = [];
  List<dynamic> _magazalarList = [];

  int _selectedDenetimTipi = 0;
  int _selectedMagaza = 0;
  TextEditingController _denetimTarihiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInspections();
    _fetchStores();
    _fetchDenetimTipi();
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

  Future<void> addInspection(
      int denetim_tipi_id, int magaza_id, String denetim_tarihi) async {
    String? token = await TokenHelper.getToken();
    int? userId = await currentUserIdHelper.getCurrentUserId();
    final response = await http.post(
      Uri.parse(ApiUrls.addInspection),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, dynamic>{
        'denetim_tipi_id': denetim_tipi_id,
        'magaza_id': magaza_id,
        'denetim_tarihi': denetim_tarihi,
        'denetci_id': userId
      }),
    );
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print("Denetim Başarılı Bir Şekilde Eklendi");
      _fetchInspections();
    } else {
      throw Exception('Failed to load inspections');
    }
  }

  Future<void> _fetchStores() async {
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.stores),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '$token'
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _magazalarList = responseData['data'];
      });
      print("Magazalar Listesi: $_magazalarList");
    } else {
      throw Exception('Failed to load stores');
    }
  }

  Future<void> _fetchDenetimTipi() async {
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.getAllInspectionType),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '$token'
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _denetimTipiList = responseData['data'];
      });
      print("Denetim Tipi Listesi: $_denetimTipiList");
    } else {
      throw Exception('Failed to load denetim tipi');
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

  void _showAddInspectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Denetim Ekle"),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Denetim Tipi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<int>(
                    onChanged: (value) {
                      setState(() {
                        _selectedDenetimTipi = value!;
                      });
                    },
                    items: _denetimTipiList.map((denetimTipi) {
                      return DropdownMenuItem<int>(
                        value: denetimTipi['denetim_tip_id'],
                        child: Text(denetimTipi['denetim_tipi']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mağaza',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<int>(
                    onChanged: (value) {
                      setState(() {
                        _selectedMagaza = value!;
                      });
                    },
                    items: _magazalarList.map((magaza) {
                      return DropdownMenuItem<int>(
                        value: magaza['magaza_id'],
                        child: Text(magaza['magaza_adi']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _denetimTarihiController.text =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                        });
                      }
                    },
                    child: Text('Tarih Seç'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                addInspection(
                  _selectedDenetimTipi,
                  _selectedMagaza,
                  _denetimTarihiController.text,
                );
              },
              child: Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Denetim Listeleri',
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
                SizedBox(width: 8.0),
                Tooltip(
                  message: "Yeni Denetim Oluştur",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _showAddInspectionDialog();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F2F9), // Arka plan rengi
                        borderRadius:
                            BorderRadius.circular(8), // Hafif border radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                            8), // İçerik ile kenarlar arasında boşluk
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF745FAB), // İkon rengi
                          size: 24, // İkon boyutu
                        ),
                      ),
                    ),
                  ),
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

  Future<void> uploadImage(
      Uint8List? bytes, String fileName, int soruId) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:5000/upload'));
    request.files
        .add(http.MultipartFile.fromBytes('photo', bytes!, filename: fileName));
    var res = await request.send();
    if (res.statusCode == 200) {
      var responseData = await res.stream.bytesToString();
      var publicId = jsonDecode(responseData)['public_id'];
      print("Upload successful. Public ID: $publicId");
      // set the publicId to the actionMap aksiyon_resim
      setState(() {
        _actionMap[soruId] ??= {};
        _actionMap[soruId]!['aksiyon_gorsel'] = publicId;
      });
    } else {
      print("Upload failed");
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
    final request = await http.post(
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

    if (request.statusCode == 201) {
      print('Inspection answered successfully: ${request.body}');
      Navigator.pop(context);
    } else {
      print('Failed to answer inspection: ${request.body}');
      throw Exception('Failed to answer inspection');
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Denetimi Tamamla"),
          content: Text("Denetimi tamamlamak istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Onayla"),
              onPressed: () {
                Navigator.of(context).pop();
                _answerInspection(widget.inspection);
                // send denetim_id to mail function
                _sendMail(widget.inspection['denetim_id']);
              },
            ),
          ],
        );
      },
    );
  }

// sendmail send denetim_id
  Future<void> _sendMail(int denetim_id) async {
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.sendEmail),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': '$token'
      },
      body: jsonEncode(<String, dynamic>{
        'denetim_id': denetim_id,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Mail Başarılı Bir Şekilde Gönderildi");
    } else {
      throw Exception('Failed to load inspection questions');
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Mağaza Adı: ${widget.inspection['magaza_adi']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Sorular:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Center(
              child: ElevatedButton(
                onPressed: _showConfirmationDialog,
                child: Text('Denetimi Tamamla'),
              ),
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
                  // onPressed: () {
                  //   uploadFile(_filePath, _fileName);
                  // },
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
  String _fileName = '';

  // void _openFilePicker() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     setState(() {
  //       List<int> bytes = result.files.first.bytes!;
  //       _filePath = result.files.first.path!;
  //       _fileName = result.files.first.name!;
  //       print("result is: $result");
  //       print("result files first bytes : ${result.files.first.bytes}");
  //       print("_filePath: $_filePath");
  //       print("_fileName: $_fileName");
  //     });
  //   }
  // }

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
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    Uint8List fileBytes = result.files.first.bytes!;
                    String fileName = result.files.first.name;
                    uploadImage(fileBytes, fileName, soruId);
                  } else {
                    print('No file selected');
                  }
                },
                child: Text('Select a file'),
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
