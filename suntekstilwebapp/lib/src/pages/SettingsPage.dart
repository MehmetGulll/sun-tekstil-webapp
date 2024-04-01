import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/custom_scaffold.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: 'Ayarlar',
      body: Center(
        child: Text('Ayarlar Sayfası İçeriği'),
      ),
    );
  }
}
