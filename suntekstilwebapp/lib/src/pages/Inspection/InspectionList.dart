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
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:toastification/toastification.dart';

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
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text('Filtreleme Başarılı!.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    _fetchInspections();
  }

  void _clearFilters() {
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text('Filtreler Kaldırıldı!.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 5),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
    });
    _fetchInspections();
  }

  void _performInspection(Map<String, dynamic> inspection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspectionScreen(inspection: inspection),
      ),
    );
  }

  void _viewDetail(Map<String, dynamic> inspection) {
    print("Denetimin Detayları: $inspection");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(inspection: inspection)),
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
                        hintText:
                            'Arama yapın... ( mağaza adı, şehir, denetçi, denetim tipi )',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _applyFilters,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                // ElevatedButton(
                //   onPressed: () async {
                //     final selectedStartDate = await showDatePicker(
                //       context: context,
                //       initialDate: DateTime.now(),
                //       firstDate: DateTime(2000),
                //       lastDate: DateTime(2100),
                //     );
                //     setState(() {
                //       _startDate = selectedStartDate;
                //     });
                //   },
                //   child: Text(_startDate == null
                //       ? 'Başlangıç Tarihi'
                //       : DateFormat('dd.MM.yyyy')
                //           .format(_startDate!)
                //           .substring(0, 10)),
                // ), // Başlangıç Tarihi TOOLTIP
                Tooltip(
                  message:
                      "Başlangıç Tarihi Seçmek İçin Tıklayınız (Denetim Tarihi)",
                  child: ElevatedButton(
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
                ),
                SizedBox(width: 8.0),
                Tooltip(
                  message:
                      "Bitiş Tarihi Seçmek İçin Tıklayınız (Denetim Tarihi)",
                  child: ElevatedButton(
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
                            .format(_startDate!)
                            .substring(0, 10)),
                  ),
                ),
                SizedBox(width: 8.0),
                Tooltip(
                  message: "Filtrele",
                  child: IconButton(
                      icon: Icon(Icons.filter_alt),
                      onPressed: () {
                        _applyFilters();
                      }),
                ),
                Tooltip(
                  message: "Filtreleri Temizle",
                  child: IconButton(
                      icon: Icon(Icons.delete_forever_sharp),
                      onPressed: () {
                        _clearFilters();
                      }),
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
                        child: Text('Mağaza Adı',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Şehir
                        child: Text('Şehir',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetim Tipi
                        child: Text('Denetim Tipi',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetim Tarihi
                        child: Text('Denetim Tarihi',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 130, // Tamamlanma Tarihi
                        child: Text('Tamamlanma Tarihi',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Şehir
                        child: Text('Şehir',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120, // Denetçi
                        child: Text('Denetçi',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100, // Denetim Puanı
                        child: Text('Denetim Puanı',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 155, // Durum
                        child: Text('Durum',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Tooltip(
                          message: inspection['status'] == 0
                              ? 'Denetimin detaylarını görüntülemek için tıklayınız.'
                              : 'Denetimi gerçekleştirmek için tıklayınız.',
                          child: SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () {
                                inspection['status'] == 0
                                    ? _viewDetail(inspection)
                                    : _performInspection(inspection);
                              },
                              child: Text(
                                inspection['status'] == 0
                                    ? 'Detayı Görüntüle'
                                    : 'Denetimi Yap',
                              ),
                            ),
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

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> inspection;

  DetailScreen({required this.inspection});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<dynamic> _inspectionQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getInspectionQuestions(widget.inspection['denetim_id']);
  }

  Future<void> _getInspectionQuestions(int denetim_id) async {
    String? token = await TokenHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiUrls.getInspectionQuestions),
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
      setState(() {
        _inspectionQuestions = responseData;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load inspection questions');
    }
  }

  String _cevapToText(int cevap) {
    return cevap == 0 ? 'Hayır' : 'Evet';
  }

  Color _getAnswerColor(int verilenCevap, int dogruCevap) {
    return verilenCevap == dogruCevap ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Denetim Detay Sayfası'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Denetim Bilgileri',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16.0),
                              _buildInfoRow('Denetim Tipi',
                                  widget.inspection['denetim_tipi']),
                              _buildInfoRow('Mağaza Adı',
                                  widget.inspection['magaza_adi']),
                              _buildInfoRow('Denetim Tarihi',
                                  widget.inspection['denetim_tarihi']),
                              _buildInfoRow(
                                  'Denetim Tamamlanma Tarihi',
                                  widget
                                      .inspection['denetim_tamamlanma_tarihi']),
                              _buildInfoRow(
                                  'Denetçi', widget.inspection['denetci']),
                              _buildInfoRow('Denetim Puanı',
                                  widget.inspection['alinan_puan'].toString()),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: "PDF Oluştur",
                          child: ElevatedButton(
                            onPressed: () {
                              List<Map<String, dynamic>> formattedData =
                                  _inspectionQuestions.map((item) {
                                return {
                                  'soruAdi': item['soru'],
                                  'soruCevap':
                                      _cevapToText(item['verilen_cevap']),
                                  'soruPuan': item['soru_puan'],
                                  'dogruCevap':
                                      _cevapToText(item['dogru_cevap']),
                                };
                              }).toList();
                              createPdfAndDownload(
                                  formattedData, widget.inspection);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded),
                                SizedBox(width: 4),
                                Text('PDF'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Tooltip(
                          message: "Excel Oluştur",
                          child: ElevatedButton(
                            onPressed: () {
                              List<Map<String, dynamic>> formattedData =
                                  _inspectionQuestions.map((item) {
                                return {
                                  'soruAdi': item['soru'],
                                  'soruCevap':
                                      _cevapToText(item['verilen_cevap']),
                                  'soruPuan': item['soru_puan'],
                                  'dogruCevap':
                                      _cevapToText(item['dogru_cevap']),
                                };
                              }).toList();
                              createExcelAndDownload(
                                  formattedData, widget.inspection);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.file_download_outlined),
                                SizedBox(width: 4),
                                Text('Excel'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Denetim Soruları:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(
                              label: Text('ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Soru',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Doğru Cevap',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Verilen Cevap',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Puan',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _inspectionQuestions.map((question) {
                          return DataRow(cells: [
                            DataCell(Text(question['soru_id'].toString())),
                            DataCell(Text(question['soru'])),
                            DataCell(
                              Text(_cevapToText(question['dogru_cevap'])),
                            ),
                            DataCell(
                              Text(
                                _cevapToText(question['verilen_cevap']),
                                style: TextStyle(
                                    color: _getAnswerColor(
                                        question['verilen_cevap'],
                                        question['dogru_cevap'])),
                              ),
                            ),
                            DataCell(Text(question['soru_puan'].toString())),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

void createPdfAndDownload(List<Map<String, dynamic>> data,
    Map<String, dynamic> inspectionDetails) async {
  final pdf = pw.Document();

  final fontData = await rootBundle.load('fonts/NotoSans_Condensed-Black.ttf');
  final boldFontData =
      await rootBundle.load('fonts/NotoSans_Condensed-Black.ttf');

  final font = pw.Font.ttf(fontData);
  final boldFont = pw.Font.ttf(boldFontData);

  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            margin: pw.EdgeInsets.only(bottom: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoText('Denetim Tipi',
                    inspectionDetails['denetim_tipi'], boldFont),
                _buildInfoText(
                    'Mağaza Adı', inspectionDetails['magaza_adi'], boldFont),
                _buildInfoText('Denetim Tarihi',
                    inspectionDetails['denetim_tarihi'], boldFont),
                _buildInfoText('Denetim Tamamlanma Tarihi',
                    inspectionDetails['denetim_tamamlanma_tarihi'], boldFont),
                _buildInfoText(
                    'Denetçi', inspectionDetails['denetci'], boldFont),
                _buildInfoText('Denetim Puanı',
                    inspectionDetails['alinan_puan'].toString(), boldFont),
              ],
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(width: 1.0, color: PdfColors.grey800),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildTableCell('SORU ADI', boldFont,
                      color: PdfColors.grey300),
                  _buildTableCell('VERİLEN CEVAP', boldFont,
                      color: PdfColors.grey300),
                  _buildTableCell('SORU PUAN', boldFont,
                      color: PdfColors.grey300),
                  _buildTableCell('DOĞRU CEVAP', boldFont,
                      color: PdfColors.grey300),
                ],
              ),
              ...data.map((item) => pw.TableRow(
                    children: [
                      _buildTableCell(item['soruAdi'], font),
                      _buildTableCell(
                          item['soruCevap'] == 0 ? 'Evet' : 'Hayır', font),
                      _buildTableCell(item['soruPuan'].toString(), font),
                      _buildTableCell(
                          item['dogruCevap'] == 0 ? 'Evet' : 'Hayır', font),
                    ],
                  )),
            ],
          ),
        ],
      );
    },
  ));

  final Uint8List pdfData = await pdf.save();

  final blob = html.Blob([pdfData.buffer.asUint8List()], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = "${inspectionDetails['denetim_id']} ID'li Rapor Detay.pdf";

  anchor.click();
}

pw.Widget _buildInfoText(String label, String value, pw.Font font) {
  return pw.Container(
    margin: pw.EdgeInsets.only(bottom: 8),
    child: pw.Text('$label: $value',
        style: pw.TextStyle(
            font: font, fontSize: 14, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _buildTableCell(String text, pw.Font font, {PdfColor? color}) {
  return pw.Container(
    padding: pw.EdgeInsets.all(8),
    decoration: color != null ? pw.BoxDecoration(color: color) : null,
    child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 12)),
  );
}

void createExcelAndDownload(
    List<Map<String, dynamic>> data, Map<String, dynamic> inspectionDetails) {
  var excel = Excel.createExcel();

  Sheet sheetObject = excel['Sheet1'];

  sheetObject.setColumnWidth(0, 50);
  sheetObject.setColumnWidth(1, 35);
  sheetObject.setColumnWidth(2, 35);
  sheetObject.setColumnWidth(3, 35);

  sheetObject.cell(CellIndex.indexByString("A1")).value =
      TextCellValue('Denetim Tipi');
  sheetObject.cell(CellIndex.indexByString("B1")).value =
      TextCellValue('Mağaza Adı');
  sheetObject.cell(CellIndex.indexByString("C1")).value =
      TextCellValue('Denetim Tarihi');
  sheetObject.cell(CellIndex.indexByString("D1")).value =
      TextCellValue('Denetim Tamamlanma Tarihi');
  sheetObject.cell(CellIndex.indexByString("E1")).value =
      TextCellValue('Denetçi');
  sheetObject.cell(CellIndex.indexByString("F1")).value =
      TextCellValue('Denetim Puanı');

  sheetObject.cell(CellIndex.indexByString("A2")).value =
      TextCellValue(inspectionDetails['denetim_tipi']);
  sheetObject.cell(CellIndex.indexByString("B2")).value =
      TextCellValue(inspectionDetails['magaza_adi']);
  sheetObject.cell(CellIndex.indexByString("C2")).value =
      TextCellValue(inspectionDetails['denetim_tarihi']);
  sheetObject.cell(CellIndex.indexByString("D2")).value =
      TextCellValue(inspectionDetails['denetim_tamamlanma_tarihi']);
  sheetObject.cell(CellIndex.indexByString("E2")).value =
      TextCellValue(inspectionDetails['denetci']);
  sheetObject.cell(CellIndex.indexByString("F2")).value =
      TextCellValue(inspectionDetails['alinan_puan'].toString());

  sheetObject.cell(CellIndex.indexByString("A4")).value =
      TextCellValue('SORU ADI');
  sheetObject.cell(CellIndex.indexByString("B4")).value =
      TextCellValue('VERİLEN CEVAP');
  sheetObject.cell(CellIndex.indexByString("C4")).value =
      TextCellValue('SORU PUAN');
  sheetObject.cell(CellIndex.indexByString("D4")).value =
      TextCellValue('DOĞRU CEVAP');

  for (int i = 0; i < data.length; i++) {
    sheetObject.cell(CellIndex.indexByString('A${i + 5}')).value =
        TextCellValue(data[i]['soruAdi']);
    sheetObject.cell(CellIndex.indexByString('B${i + 5}')).value =
        TextCellValue(data[i]['soruCevap'] == 0 ? 'Evet' : 'Hayır');
    sheetObject.cell(CellIndex.indexByString('C${i + 5}')).value =
        TextCellValue(data[i]['soruPuan'].toString());
    sheetObject.cell(CellIndex.indexByString('D${i + 5}')).value =
        TextCellValue(data[i]['dogruCevap'] == 0 ? 'Evet' : 'Hayır');
  }

  var bytes = excel.encode();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = "${inspectionDetails['denetim_id']} ID'li Rapor Detay.xlsx";
  html.document.body!.children.add(anchor);

  anchor.click();

  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InspectionPage(),
  ));
}
