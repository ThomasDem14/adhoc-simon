import 'dart:math';

import 'package:adhoc_gaming/pages/organisation_page.dart';
import 'package:adhoc_gaming/pages/page_settings.dart';
import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController textController = TextEditingController();
  final List<bool> _selection =
      List.generate(2, (index) => index == 0 ? true : false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Simon Game'),
        ),
        body: Column(children: [
          // Input form for the name
          Container(
            margin: EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
              controller: textController,
            ),
          ),
          SizedBox(height: 5),
          // Toggle button for Adhoc/Nearby plugin
          ToggleButtons(
            children: [
              const Text("AdHoc"),
              const Text("Nearby"),
            ],
            isSelected: _selection,
            onPressed: (int index) {
              setState(() {
                _selection[index] = true;
                _selection[1 - index] = false;
              });
            },
          ),
          SizedBox(height: 5),
          // Button start
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 0),
                textStyle: TextStyle(color: Colors.white),
                primary: Colors.blue,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (context) => PlayerManager(
                              _uniqueName(textController.text),
                              _selection.indexOf(true))),
                      ChangeNotifierProvider(
                          create: (context) => PageSettings()),
                    ],
                    child: OrganisationPage(),
                  ),
                ));
              },
              child: const Text("Start"),
            ),
          ),
        ]));
  }

  /// Transfrorm a name into a unique one by adding 4 random digits.
  String _uniqueName(String name) {
    var rng = Random();
    var code = rng.nextInt(9000) + 1000;
    return name + "#" + code.toString();
  }
}
