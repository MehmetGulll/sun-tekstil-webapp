import 'package:flutter/material.dart';
import 'package:suntekstilwebapp/src/components/custom_scaffold.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Text('Ana Sayfa İçeriği'),
      ),
    );
  }
}
