import 'dart:math';

import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final Random randomSeed = new Random();
  final TextEditingController textController;

  MainPage({this.textController});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 5),
      // Button start game
      SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed: () => Provider.of<PlayerManager>(context, listen: false)
              .startGame(randomSeed.nextInt(0x7fffffff)),
          child: const Text("Start game with group"),
        ),
      ),
    ]);
  }
}
