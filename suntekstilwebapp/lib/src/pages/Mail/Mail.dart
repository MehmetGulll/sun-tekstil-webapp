import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:suntekstilwebapp/src/components/Button/Button.dart';
import 'package:suntekstilwebapp/src/components/Sidebar/custom_scaffold.dart';
import 'package:suntekstilwebapp/src/components/Card/Card.dart';
import 'package:suntekstilwebapp/src/components/Dropdown/Dropdown.dart';
import 'package:suntekstilwebapp/src/components/Input/Input.dart';
import 'package:suntekstilwebapp/src/constants/theme.dart';
import 'package:suntekstilwebapp/src/constants/tokens.dart';

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  List<String> _countryList = ['Country 1', 'Country 2', 'Country 3'];
  String? _chosenCountryType;
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                  child: Text(
                "Mail Yönetimi",
                style: TextStyle(
                    fontSize: Tokens.fontSize[9],
                    fontWeight: Tokens.fontWeight[6]),
              )),
              SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Themes.borderColor,
                          width: 1,
                        ),
                      ),
                      child: CustomCard(
                        color: Themes.cardBackgroundColor,
                        children: [
                          SizedBox(
                            height: 320,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    width: double.infinity,
                                    child: CustomDropdown(
                                        items: _countryList,
                                        onChanged: (value) => setState(
                                            () => _chosenCountryType = value)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Themes.borderColor,
                          width: 1,
                        ),
                      ),
                      child: CustomCard(
                        color: Themes.cardBackgroundColor,
                        children: [
                          SizedBox(
                            height: 320,
                            child: Column(
                              children: [
                                Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: CustomInput(
                                                controller:
                                                    TextEditingController(),
                                                hintText: 'Yeni Mail Giriniz.',
                                                keyboardType:
                                                    TextInputType.name)),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        CustomButton(
                                            buttonText: 'Ekle',
                                            onPressed: () {
                                              print("Eklend");
                                            })
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                  buttonText: 'Mail Gönder',
                  onPressed: () {
                    print("Gönderildi");
                  })
            ],
          ),
        ),
      ),
    );
  }
}
