import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_reactive_ble/ble_manager.dart';
import 'package:test_reactive_ble/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => BleManager(),
        child: const MainPage(),
      ),
    );
  }
}
