import 'package:adhoc_gaming/model/player.dart';
import 'package:adhoc_gaming/view/main_page.dart';
import 'package:adhoc_gaming/view/room_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Player(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AdHoc Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => MainPage(),
          '/room': (context) => RoomPage(),
        },
        initialRoute: '/',
      ),
    );
  }
}
