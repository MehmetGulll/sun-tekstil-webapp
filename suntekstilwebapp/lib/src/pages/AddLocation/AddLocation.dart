import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suntekstilwebapp/src/Context/GlobalStates.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/ErrorDialog.dart';
import 'package:suntekstilwebapp/src/components/Dialogs/SucessDialog.dart';
import 'package:http/http.dart' as http;

class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

Widget buildColumn(BuildContext context, String label, List<String> items,
    ValueChanged<String?> onChanged) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: Tokens.fontSize[4]),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: CustomDropdown(
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

class _AddLocationState extends State<AddLocation> {
  Map<String, int> storeType = {'AVM': 1, 'CADDE': 2};

  final TextEditingController storeCodeController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeCityController = TextEditingController();
  final TextEditingController storePhoneNumberController =
      TextEditingController();
  final TextEditingController storeWidthController = TextEditingController();
  TextEditingController storeTypeController = TextEditingController();
  final TextEditingController storeEmailController = TextEditingController();
  @override
  void dispose() {
    // burası dropdown değişince input içi değişmesin diye konuldu
    storeCodeController.dispose();
    storeNameController.dispose();
    storeCityController.dispose();
    storePhoneNumberController.dispose();
    storeWidthController.dispose();
    super.dispose();
  }

  final TextInputType keyboardType = TextInputType.text;



  List<String> _storeManagerType = [
    '1',
    '2',
  ];
  Future<void> addStore(BuildContext context) async {
    final auth = Provider.of<Auth>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentUserId = prefs.getInt("currentUserId") ?? 0;

    int? selectedStoreType = storeType[storeTypeController.text];

    print(storeCodeController);
    print(storeNameController);
    print(storeTypeController);
    print(storeCityController);
    print(storePhoneNumberController);
    print(storeWidthController);
    print(currentUserId);
    print(storeEmailController);
    final response = await http.post(Uri.parse(ApiUrls.addStore), body: {
      'storeCode': storeCodeController.text,
      'storeName': storeNameController.text,
      'storeType': selectedStoreType.toString(),
      'city': storeCityController.text,
      'storePhone': storePhoneNumberController.text,
      'storeWidth': storeWidthController.text,
      'addId': currentUserId.toString(),
      'storeEmail': storeEmailController.text
    });
    if (response.statusCode == 200) {
      print("Mağaza eklendi");
      String successMessage = "Mağaza Başarıyla Eklendi!!";
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SuccessDialog(
              successMessage: successMessage,
              successIcon: Icons.check,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/stores');
              },
            );
          });
    } else {
      print("Bir hata oluştu");
      String errorMessage = "Bir hata oluştu!!";
      print("Hata");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorMessage: errorMessage,
              errorIcon: Icons.error,
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Mağaza Ekle',
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            children: [
              Column(
                children: [
                  Text("Mağaza Kodu",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storeCodeController,
                      hintText: 'Mağaza Kodu',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Mağaza Adı",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storeNameController,
                      hintText: 'Mağaza Adı',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Mağaza Tipi", storeType.keys.toList(),
                  (value) => setState(() => storeTypeController.text = value!)),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Şehir", style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storeCityController,
                      hintText: 'Şehir',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Mağaza Telefon Numarası",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storePhoneNumberController,
                      hintText: 'Mağaza Telefon Numarası',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Mağaza Metrekaresi",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storeWidthController,
                      hintText: 'Mağaza Metrekaresi',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Mağaza Email Adresi",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: storeEmailController,
                      hintText: 'Mağaza Email Adres',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                      buttonText: 'Ekle',
                      textColor: Themes.blackColor,
                      buttonColor: Themes.cardBackgroundColor,
                      onPressed: () {
                        addStore(context);
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
