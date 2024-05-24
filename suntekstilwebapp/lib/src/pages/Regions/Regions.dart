import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';

class Regions extends StatefulWidget {
  @override
  _RegionsPageState createState() => _RegionsPageState();
}

class _RegionsPageState extends State<Regions> {
  List<dynamic> _allRegions = [];
  List<dynamic> _allUsers = [];
  int _currentPage = 1;
  int _totalPages = 1;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    _getUsers();
  }

  Future<void> _fetchRegions() async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'page': _currentPage,
    };
    if (_searchController.text.isNotEmpty) {
      requestBody['searchTerm'] = _searchController.text;
    }

    final response = await http.post(
      Uri.parse(ApiUrls.getAllRegion),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _allRegions = responseData['allRegion']['rows'];
        _totalPages = (responseData['total'] / responseData['perPage']).ceil();
      });
    } else {
      throw Exception('Failed to load regions.');
    }
  }

  Future<void> _updateRegion(
      int regionId, Map<String, dynamic> updatedFields) async {
    String? token = await TokenHelper.getToken();
    updatedFields['bolge_id'] = regionId;

    final response = await http.post(
      Uri.parse(ApiUrls.updateRegion),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 200) {
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text(' Bölge başarıyla güncellendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      _fetchRegions();
    } else {
      throw Exception('Failed to update region.');
    }
  }

  Future<void> _getUsers() async {
    String? token = await TokenHelper.getToken();
    final response = await http.get(
      Uri.parse(ApiUrls.getAllUsers),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        _allUsers = responseData;
      });
    } else {
      throw Exception('Failed to load users.');
    }
  }

  Future<void> _addRegion(Map<String, dynamic> newRegion) async {
    String? token = await TokenHelper.getToken();

    final response = await http.post(
      Uri.parse(ApiUrls.addRegion),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(newRegion),
    );

    if (response.statusCode == 201) {
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Yeni Bölge başarıyla eklendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      _fetchRegions();
    } else {
      throw Exception('Failed to add region.');
    }
  }

  void _showAddRegionDialog() {
    TextEditingController bolgeAdiController = TextEditingController();
    TextEditingController bolgeKoduController = TextEditingController();
    int bolgeMuduruId = _allUsers.isNotEmpty ? _allUsers[0]['id'] : 0;
    int status = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Yeni Bölge Oluştur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bolgeAdiController,
                decoration: InputDecoration(labelText: 'Bölge Adı'),
              ),
              TextField(
                controller: bolgeKoduController,
                decoration: InputDecoration(labelText: 'Bölge Kodu'),
              ),
              DropdownButtonFormField<int>(
                value: bolgeMuduruId,
                items: _allUsers.map<DropdownMenuItem<int>>((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text('${user['ad']} ${user['soyad']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bolgeMuduruId = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Bölge Müdürü ID'),
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
                decoration: InputDecoration(labelText: 'Durum'),
                disabledHint: Text("Aktif"),
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
                Map<String, dynamic> newRegion = {
                  'bolge_adi': bolgeAdiController.text,
                  'bolge_kodu': bolgeKoduController.text,
                  'bolge_muduru': bolgeMuduruId
                };
                _addRegion(newRegion);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> region) {
    TextEditingController bolgeAdiController =
        TextEditingController(text: region['bolge_adi']);
    TextEditingController bolgeKoduController =
        TextEditingController(text: region['bolge_kodu']);
    int bolgeMuduruId = region['bolge_muduru'];
    int status = region['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bölge Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bolgeAdiController,
                decoration: InputDecoration(labelText: 'Bölge Adı'),
              ),
              TextField(
                controller: bolgeKoduController,
                decoration: InputDecoration(labelText: 'Bölge Kodu'),
              ),
              DropdownButtonFormField<int>(
                value: bolgeMuduruId,
                items: _allUsers.map<DropdownMenuItem<int>>((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text('${user['ad']} ${user['soyad']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bolgeMuduruId = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Bölge Müdürü ID'),
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
                decoration: InputDecoration(labelText: 'Durum'),
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
                Map<String, dynamic> updatedFields = {
                  'bolge_adi': bolgeAdiController.text,
                  'bolge_kodu': bolgeKoduController.text,
                  'bolge_muduru': bolgeMuduruId,
                  'status': status,
                };
                _updateRegion(region['bolge_id'], updatedFields);
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
      pageTitle: 'Bölgeler',
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
                Tooltip(
                  message: "Filtrele",
                  child: IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: _applyFilters,
                  ),
                ),
                SizedBox(width: 8.0),
                Tooltip(
                  message: "Filtreleri Temizle",
                  child: IconButton(
                    icon: Icon(Icons.delete_forever_sharp),
                    onPressed: _clearFilters,
                  ),
                ),
                SizedBox(width: 8.0),
                Tooltip(
                  message: "Yeni Bölge Oluştur",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _showAddRegionDialog();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F2F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF745FAB),
                          size: 24,
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
              padding: const EdgeInsets.all(40.0),
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text('Bölge Adı',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      tooltip: 'Bölge Adı'),
                  DataColumn(
                      label: Text('Bölge Kodu',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      tooltip: 'Bölge Kodu'),
                  DataColumn(
                      label: Text('Durum',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      tooltip: 'Durum'),
                  DataColumn(
                      label: Text('Bölge Müdürü ID',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      tooltip: 'Bölge Müdürü ID'),
                  DataColumn(
                      label: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      tooltip: 'Actions'),
                ],
                rows: _allRegions.map((region) {
                  return DataRow(
                    cells: [
                      DataCell(Text(region['bolge_adi'])),
                      DataCell(Text(region['bolge_kodu'])),
                      DataCell(Text(
                        region['status'] == 1 ? 'Aktif' : 'Pasif',
                      )),
                      DataCell(Text(
                          '${region['bolgeMuduru']['ad']} ${region['bolgeMuduru']['soyad']}')),
                      DataCell(Row(
                        children: [
                          Tooltip(
                            message: "Düzenle",
                            child: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(region);
                              },
                            ),
                          )
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          PaginationControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
              _fetchRegions();
            },
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text(' Filtreler uygulandı.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    _fetchRegions();
  }

  void _clearFilters() {
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text(' Filtreler temizlendi.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    _searchController.clear();
    _fetchRegions();
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text('$currentPage / $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
