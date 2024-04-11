import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

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
  final TextEditingController controller = TextEditingController();
  final TextInputType keyboardType = TextInputType.text;
  String? _chosenCountry;
  String? _chosenCity;
  String? _chosenRegion;
  String? _chosenLocationManager;
  String? _chosenCounty;
  List<String> _countryList = ['Country 1', 'Country 2', 'Country 3'];
  List<String> _operationList = ['City 1 ', 'City 2', 'City 3'];
  List<String> _regionList = ['Region 1', 'Region 2', 'Region 3'];
  List<String> _locationManagerList = [
    'Location Manager 1',
    'Location Manager 2',
    'Location Manager 3'
  ];
  List<String> _countyList = ['County 1', 'County 2', 'County 3'];

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
                  Text("Lokasyon Kodu",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Lokasyon Kodu',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Lokasyon Adresi",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Lokasyon Adresi',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Enlem", style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Enlem',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Boylam",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Boylam',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Lokasyon Telefon Numarası",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Lokasyon Telefon Numarası',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Lokasyon Metrekaresi",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Lokasyon Metrekaresi',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Lokasyon Tipi",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Lokasyon Tipi',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Text("Açıklama",
                      style: TextStyle(fontSize: Tokens.fontSize[4])),
                  CustomInput(
                      controller: TextEditingController(),
                      hintText: 'Açıklama',
                      keyboardType: TextInputType.text)
                ],
              ),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Bölge", _regionList,
                  (value) => setState(() => _chosenRegion = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Lokasyon Müdürü", _locationManagerList,
                  (value) => setState(() => _chosenLocationManager = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Ülke", _countryList,
                  (value) => setState(() => _chosenCountry = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "Şehir", _operationList,
                  (value) => setState(() => _chosenCity = value)),
              SizedBox(
                height: 30,
              ),
              buildColumn(context, "İlçe", _countyList,
                  (value) => _chosenCounty = value),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: CustomButton(
                      buttonText: 'Ekle',
                      onPressed: () {
                        print("Eklendi");
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
