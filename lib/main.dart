import 'package:adhoc_gaming/pages/game_page.dart';
import 'package:adhoc_gaming/pages/organisation_page.dart';
import 'package:adhoc_gaming/pages/page_settings.dart';
import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlayerManager()),
        ChangeNotifierProvider(create: (context) => PageSettings()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AdHoc Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => OrganisationPage(),
          '/game': (context) => GamePage(),
        },
        initialRoute: '/',
      ),
    );
  }
}
