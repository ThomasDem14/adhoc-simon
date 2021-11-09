import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/pages/main_page.dart';
import 'package:adhoc_gaming/pages/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => new AdhocPlayer(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AdHoc Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => MainPage(),
          '/game': (context) => GamePage(),
        },
        initialRoute: '/',
      ),
    );
  }
}
