import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';

class InspectionTypePage extends StatefulWidget {
  @override
  _InspectionTypePageState createState() => _InspectionTypePageState();
}

class _InspectionTypePageState extends State<InspectionTypePage> {
  List<dynamic> _allInspectionTypes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInspectionTypes();
  }

  Future<void> _fetchInspectionTypes() async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'page': _currentPage,
    };

    if (_searchController.text.isNotEmpty) {
      requestBody['searchTerm'] = _searchController.text;
    }

    final response = await http.post(
      Uri.parse(ApiUrls.getAllInspectionType),
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
        _allInspectionTypes = responseData['data'];
        _totalPages = responseData['count'] ~/ responseData['perPage'] +
            ((responseData['count'] % responseData['perPage'] == 0) ? 0 : 1);
      });
    } else {
      throw Exception('Failed to load inspection types.');
    }
  }

  Future<void> _updateInspectionType(
      int denetim_tipi_id, Map<String, dynamic> updatedFields) async {
    String? token = await TokenHelper.getToken();
    updatedFields['denetim_tipi_id'] = denetim_tipi_id;

    final response = await http.post(
      Uri.parse(ApiUrls.updateInspectionType),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Denetim tipi başarıyla güncellendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 5),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );

      final responseData = json.decode(response.body);
      print("responseData: $responseData");
      _fetchInspectionTypes();
    } else {
      toastification.show(
          context: context,
          title: Text('Hata'),
          description: Text('Denetim tipi güncellenirken bir hata oluştu.'),
          type: ToastificationType.error,
          icon: const Icon(Icons.error),
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true);

      throw Exception('Failed to update inspection type.');
    }
  }

  void _showEditDialog(Map<String, dynamic> inspectionType) {
    TextEditingController denetimTipiController =
        TextEditingController(text: inspectionType['denetim_tipi']);
    TextEditingController denetimTipiKoduController =
        TextEditingController(text: inspectionType['denetim_tipi_kodu']);
    int status = inspectionType['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Denetim Tipi Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: denetimTipiController,
                decoration: InputDecoration(labelText: 'Denetim Tipi'),
              ),
              TextField(
                controller: denetimTipiKoduController,
                decoration: InputDecoration(labelText: 'Denetim Tipi Kodu'),
              ),
              DropdownButtonFormField<int>(
                value: status,
                items: [
                  DropdownMenuItem(value: 1, child: Text("Aktif")),
                  DropdownMenuItem(value: 0, child: Text("Pasif")),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Kaydet"),
              onPressed: () {
                Map<String, dynamic> updatedFields = {};
                if (denetimTipiController.text !=
                    inspectionType['denetim_tipi']) {
                  updatedFields['denetim_tipi'] = denetimTipiController.text;
                }
                if (denetimTipiKoduController.text !=
                    inspectionType['denetim_tipi_kodu']) {
                  updatedFields['denetim_tipi_kodu'] =
                      denetimTipiKoduController.text;
                }
                if (status != inspectionType['status']) {
                  updatedFields['status'] = status;
                }

                if (updatedFields.isNotEmpty) {
                  _updateInspectionType(
                      inspectionType['denetim_tip_id'], updatedFields);
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addInspectionType(
      Map<String, dynamic> newInspectionType) async {
    String? token = await TokenHelper.getToken();

    final response = await http.post(
      Uri.parse(ApiUrls.addInspectionType),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(newInspectionType),
    );

    if (response.statusCode == 201) {
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Denetim tipi başarıyla eklendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 5),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );

      final responseData = json.decode(response.body);
      print("responseData: $responseData");
      _fetchInspectionTypes();
    } else {
      toastification.show(
          context: context,
          title: Text('Hata'),
          description: Text('Denetim tipi eklenirken bir hata oluştu.'),
          type: ToastificationType.error,
          icon: const Icon(Icons.error),
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 5),
          showProgressBar: true,
          pauseOnHover: true,
          dragToClose: true,
          applyBlurEffect: true);

      throw Exception('Failed to add inspection type.');
    }
  }

  void _showAddInspectionTypeDialog() {
    TextEditingController denetimTipiController = TextEditingController();
    TextEditingController denetimTipiKoduController = TextEditingController();
    int status = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Yeni Denetim Tipi Oluştur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: denetimTipiController,
                decoration: InputDecoration(labelText: 'Denetim Tipi'),
              ),
              TextField(
                controller: denetimTipiKoduController,
                decoration: InputDecoration(labelText: 'Denetim Tipi Kodu'),
              ),
              DropdownButtonFormField<int>(
                value: status,
                items: [
                  DropdownMenuItem(value: 1, child: Text("Aktif")),
                  DropdownMenuItem(value: 0, child: Text("Pasif")),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Kaydet"),
              onPressed: () {
                Map<String, dynamic> newInspectionType = {
                  'denetim_tipi': denetimTipiController.text,
                  'denetim_tipi_kodu': denetimTipiKoduController.text,
                  'status': status,
                };

                _addInspectionType(newInspectionType);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                message: "Yeni Denetim Tipi Oluştur",
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _showAddInspectionTypeDialog();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Her satırda 4 kart
                crossAxisSpacing: 8.0, // Yatay boşluk
                mainAxisSpacing: 8.0, // Dikey boşluk
              ),
              itemCount: _allInspectionTypes.length,
              itemBuilder: (context, index) {
                final inspectionType = _allInspectionTypes[index];
                return Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 3,
                  child: SizedBox( // Yükseklik için SizedBox kullanıyoruz
                    height: 200, // Kartın maksimum yüksekliği
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID: ${inspectionType['denetim_tip_id']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    _showEditDialog(inspectionType),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Denetim Tipi: ${inspectionType['denetim_tipi']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Denetim Tipi Kodu: ${inspectionType['denetim_tipi_kodu']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Status: ${inspectionType['status'] == 1 ? 'Aktif' : 'Pasif'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: inspectionType['status'] == 1
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
    _fetchInspectionTypes();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _currentPage = 1;
    });
    _fetchInspectionTypes();
  }

  void _previousPage() {
    setState(() {
      _currentPage--;
    });
    _fetchInspectionTypes();
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchInspectionTypes();
  }
}
