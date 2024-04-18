import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';
import 'package:suntekstilwebapp/src/API/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
  final TextEditingController storeCodeController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storeCityController = TextEditingController();
  final TextEditingController storePhoneNumberController = TextEditingController();
  final TextEditingController storeWidthController = TextEditingController();
  @override
  void dispose() {
    storeCodeController.dispose();
    storeNameController.dispose();
    storeCityController.dispose();
    storePhoneNumberController.dispose();
    storeWidthController.dispose();
    super.dispose();
  }

  final TextInputType keyboardType = TextInputType.text;
  String? _chosenCountry;
  String? _chosenCity;
  String? _chosenRegion;
  String? _chosenLocationManager;
  String? _chosenCounty;
  String? _chosenStoreType;
  String? _chosenManagerType;
  List<String> _countryList = ['Country 1', 'Country 2', 'Country 3'];
  List<String> _storeTypeList = ['1 ', '2'];
  List<String> _regionList = ['Region 1', 'Region 2', 'Region 3'];
  List<String> _storeManagerType = [
    '1',
    '2',
  ];
  List<String> _countyList = ['County 1', 'County 2', 'County 3'];
  Future<void>addStore(BuildContext context) async{
    print(storeCodeController);
    print(storeNameController);
    print(storeCityController);
    print(_chosenStoreType);
    print(storeCityController);
    print(storePhoneNumberController);
    print(storeWidthController);
    print(storeWidthController);
    final response = await http.post(Uri.parse(ApiUrls.addStore), body:{
      'storeCode':storeCodeController.text,
      'storeName':storeNameController.text,
      'storeType':_chosenStoreType,
      'city':storeCityController.text,
      'storePhone':storePhoneNumberController.text,
      'storeWidth':storeWidthController.text,
      'storeManager':_chosenManagerType
    } );
    if(response.statusCode ==200){
      print("Mağaza eklendi");
    }
    else{
      print("Bir hata oluştu");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
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
              buildColumn(context, "Mağaza Tipi", _storeTypeList,
                  (value) => setState(() => _chosenStoreType = value)),
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
              buildColumn(context, "Mağaza Müdürü", _storeManagerType,
                  (value) => setState(() => _chosenManagerType = value)),
              SizedBox(
                height: 30,
              ),
             
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                      buttonText: 'Ekle',
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
