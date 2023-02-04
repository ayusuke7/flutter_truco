import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_truco/pages/menu_page.dart';
import 'package:flutter_truco/styles/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, 
    DeviceOrientation.landscapeRight
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Truco em Rede',
      theme: ThemeCustom.theme(),
      home: MenuPage(),
    );
  }
}
