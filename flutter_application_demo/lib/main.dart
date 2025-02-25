import 'package:flutter/material.dart';
import 'package:namer_app/pages/map_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPage(),
    );
  }
}
