import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/utils/token_helper.dart';
import 'dart:convert';
import 'package:toastification/toastification.dart';

class OfficalUsers extends StatefulWidget {
  @override
  _OfficalUsersState createState() => _OfficalUsersState();
}

class _OfficalUsersState extends State<OfficalUsers> {
  List<dynamic> _allUsers = [];
  List<dynamic> _allRoles = [];
  List<dynamic> _allTitles = [];
  int _currentPage = 1;
  int _totalPages = 1;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchRoles() async {
    try {
      String? token = await TokenHelper.getToken();
      final response = await http.get(
        Uri.parse(ApiUrls.roles),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Roles Response Data: $responseData");

        if (responseData is List) {
          setState(() {
            _allRoles = responseData;
          });
        } else {
          print("Unexpected data format for roles");
        }
      } else {
        print("Failed to load roles");
      }
    } catch (error) {
      print("Error fetching roles: $error");
    }
  }

  Future<void> _fetchTitles() async {
    try {
      String? token = await TokenHelper.getToken();
      final response = await http.get(
        Uri.parse(ApiUrls.unvanlar),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Titles Response Data: $responseData");

        if (responseData is List) {
          setState(() {
            _allTitles = responseData;
          });
        } else {
          print("Unexpected data format for titles");
        }
      } else {
        print("Failed to load titles");
      }
    } catch (error) {
      print("Error fetching titles: $error");
    }
  }

  Future<void> _fetchUsers() async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'page': _currentPage,
    };
    if (_searchController.text.isNotEmpty) {
      requestBody['searchTerm'] = _searchController.text;
      requestBody['page'] = 1;
    }

    final response = await http.post(
      Uri.parse(ApiUrls.users),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Fetch Users: $responseData");
      setState(() {
        _allUsers = responseData['data'];
        _totalPages = (responseData['total'] / responseData['perPage']).ceil();
      });
      print("abcTotal Pages: $_totalPages");
      print("abcCurrent Page: $_currentPage");
      print("abcAll Users: $_allUsers");
      _fetchRoles();
      _fetchTitles();
    } else {
      print("Failed to load users");
    }
  }

  Future<void> _updateUserStatus(int userId, int status) async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'id': userId,
      'status': status,
    };

    final response = await http.post(
      Uri.parse(ApiUrls.updateUserStatus),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Update User Status: $responseData");
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Kullanıcı durumu başarıyla güncellendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      _fetchUsers();
    } else {
      toastification.show(
        context: context,
        title: Text('Hata'),
        description: Text('Kullanıcı durumu güncellenirken bir hata oluştu.'),
        icon: const Icon(Icons.error),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
    print("Failed to update user status");
    }
  }

  Future<void> _showConfirmDialog(int status, int id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kullanıcı Aktifliği Değiştirme'),
          content: Text(
            status == 1
                ? 'Kullanıcıyı pasif hale getirmek istediğinize emin misiniz?'
                : 'Kullanıcıyı aktif hale getirmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _updateUserStatus(id, status == 0 ? 1 : 0);
                Navigator.of(context).pop();
              },
              child: Text('Onayla'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateSelectedUser(
      int userId,
      String name,
      String surname,
      String username,
      String email,
      int roleId,
      int titleId,
      int status) async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'id': userId,
      'ad': name,
      'soyad': surname,
      'kullanici_adi': username,
      'eposta': email,
      'rol': roleId,
      'unvan_id': titleId,
      'status': status,
    };

    final response = await http.post(
      Uri.parse(ApiUrls.updateSelectedUser),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Update User $responseData");
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Kullanıcı başarıyla güncellendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      _fetchUsers();
    } else {
      toastification.show(
        context: context,
        title: Text('Hata'),
        description: Text('Kullanıcı güncellenirken bir hata oluştu.'),
        icon: const Icon(Icons.error),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      print("Failed to update user");
    }
  }

  Future<void> _showUpdateUserDialog(
      int userId,
      String name,
      String surname,
      String username,
      String email,
      int? roleId,
      int? titleId,
      int status) async {
    TextEditingController _nameController = TextEditingController(text: name);
    TextEditingController _surnameController =
        TextEditingController(text: surname);
    TextEditingController _usernameController =
        TextEditingController(text: username);
    TextEditingController _emailController = TextEditingController(text: email);
    int selectedRoleId = roleId!;
    int selectedTitleId = titleId!;
    int selectedStatus = status;
    print(
        "User Informations: $userId, $name, $surname, $username, $email, $roleId, $titleId, $status");
    print("User InformationAll Roles: $_allRoles");
    print("User InformationAll Titles: $_allTitles");
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kullanıcı Bilgilerini Güncelle'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 600.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'İsim'),
                      ),
                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(labelText: 'Soyisim'),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'E-Mail'),
                      ),
                      DropdownButtonFormField(
                        value: selectedRoleId,
                        items: _allRoles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role['rol_id'],
                                child: Text(role['rol_adi']),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRoleId = value as int;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Rol'),
                      ),
                      DropdownButtonFormField(
                        value: selectedTitleId,
                        items: _allTitles
                            .map(
                              (title) => DropdownMenuItem(
                                value: title['unvan_id'],
                                child: Text(title['unvan_adi']),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTitleId = value as int;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Ünvan'),
                      ),
                      DropdownButtonFormField<int>(
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Pasif'),
                          ),
                        ],
                        value: selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Durum'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _updateSelectedUser(
                  userId,
                  _nameController.text,
                  _surnameController.text,
                  _usernameController.text,
                  _emailController.text,
                  selectedRoleId,
                  selectedTitleId,
                  selectedStatus,
                );
                Navigator.of(context).pop();
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addUser(String name, String surname, String username,
      String email, String password, int roleId, int titleId) async {
    String? token = await TokenHelper.getToken();
    Map<String, dynamic> requestBody = {
      'ad': name,
      'soyad': surname,
      'kullanici_adi': username,
      'eposta': email,
      'sifre': password,
      'rol': roleId,
      'unvan_id': titleId,
    };

    final response = await http.post(
      Uri.parse(ApiUrls.addUser),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token'
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print("Add User $responseData");
      toastification.show(
        context: context,
        title: Text('Başarılı'),
        description: Text('Kullanıcı başarıyla eklendi.'),
        icon: const Icon(Icons.check),
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
      _fetchUsers();
    } else {
      toastification.show(
        context: context,
        title: Text('Hata'),
        description: Text("Kullanıcı eklenemedi. Lütfen tekrar deneyin."),
        icon: const Icon(Icons.error),
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 3),
        showProgressBar: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
    }
  }

  Future<void> _showAddUserDialog() async {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _surnameController = TextEditingController();
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    int selectedRoleId = 6;
    int selectedTitleId = 12;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yeni Kullanıcı Ekle'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 600.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'İsim'),
                      ),
                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(labelText: 'Soyisim'),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'E-Mail'),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Şifre'),
                      ),
                      DropdownButtonFormField(
                        value: selectedRoleId,
                        items: _allRoles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role['rol_id'],
                                child: Text(role['rol_adi']),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRoleId = value as int;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Rol'),
                      ),
                      DropdownButtonFormField(
                        value: selectedTitleId,
                        items: _allTitles
                            .map(
                              (title) => DropdownMenuItem(
                                value: title['unvan_id'],
                                child: Text(title['unvan_adi']),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTitleId = value as int;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Ünvan'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _addUser(
                  _nameController.text,
                  _surnameController.text,
                  _usernameController.text,
                  _emailController.text,
                  _passwordController.text,
                  selectedRoleId,
                  selectedTitleId,
                );
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Yetkili Kullanıcı Yönetimi',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Arama yapın...(Ad, Soyad, Kullanıcı Adı, E-Mail)',
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
                  message: "Filtreleri Uygula",
                  child: IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: _applyFilters,
                  ),
                ),
                Tooltip(
                  message: "Filtreleri Temizle",
                  child: IconButton(
                    icon: Icon(Icons.delete_forever_sharp),
                    onPressed: _clearFilters,
                  ),
                ),
                SizedBox(width: 8.0),
                Tooltip(
                  message: "Yeni Yetkili Kullanıcı Oluştur",
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _showAddUserDialog();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F2F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFF745FAB),
                              size: 24,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Yeni Kullanıcı Ekle',
                              style: TextStyle(
                                color: Color(0xFF745FAB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          SizedBox(height: 12.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 36.0,
                    columns: [
                      DataColumn(
                        label: Text('ID',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('İsim',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Soyisim',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Kullanıcı Adı',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('E-Mail',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Rol Adı',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Ünvan Adı',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      DataColumn(
                        label: Text('İşlemler',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                    rows: _allUsers
                        .map(
                          (user) => DataRow(
                            cells: [
                              DataCell(Text(user['id'].toString())),
                              DataCell(Text(user['ad'])),
                              DataCell(Text(user['soyad'])),
                              DataCell(Text(user['kullanici_adi'])),
                              DataCell(Text(user['eposta'])),
                              DataCell(Text(user['rol_adi'])),
                              DataCell(Text(user['unvan_adi'])),
                              DataCell(Tooltip(
                                message:
                                    user['status'] == 1 ? 'Aktif' : 'Pasif',
                                child: Switch(
                                  value: user['status'] == 1,
                                  onChanged: (value) {
                                    _showConfirmDialog(
                                        user['status'], user['id']);
                                  },
                                  activeColor: user['status'] == 1
                                      ? Colors.green
                                      : Colors.grey,
                                  inactiveThumbColor: user['status'] == 1
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              )),
                              DataCell(
                                Tooltip(
                                  message: 'Kullanıcı Bilgilerini Güncelle',
                                  child: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showUpdateUserDialog(
                                        user['id'],
                                        user['ad'],
                                        user['soyad'],
                                        user['kullanici_adi'],
                                        user['eposta'],
                                        user['rol_id'] ?? 6,
                                        user['unvan_id'] ?? 1,
                                        user['status'],
                                      );
                                    },
                                  ),
                                ),
                              ),
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
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text('Filtreleme Başarılı!.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    setState(() {
      _currentPage = 1;
    });
    _fetchUsers();
  }

  void _clearFilters() {
    toastification.show(
      context: context,
      title: Text('Başarılı'),
      description: Text('Filtreleme Başarılı!.'),
      icon: const Icon(Icons.check),
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
    setState(() {
      _searchController.clear();
      _currentPage = 1;
    });
    _fetchUsers();
  }

  void _previousPage() {
    setState(() {
      _currentPage--;
    });
    _fetchUsers();
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchUsers();
  }
}
