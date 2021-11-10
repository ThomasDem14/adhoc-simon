import 'dart:math';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  static final Random random = new Random();

  int _level = 1;
  int _nbPlayers;

  // The sequence consists of a sequence of colors per player
  List<List<GameColors>> _sequence;

  SimonGame(int nbPlayers) {
    _nbPlayers = nbPlayers;

    // Generate a new empty list for each player
    _sequence =
        new List.generate(nbPlayers, (index) => new List.empty(growable: true));
  }

  GameColors _randomColor() {
    return GameColors.values[random.nextInt(GameColors.values.length)];
  }

  void incrementLevel() {
    // Add 1 new color for each player
    for (var i = 1; i < _nbPlayers; i++)
      _sequence.elementAt(i).add(_randomColor());

    _level++;
    notifyListeners();
  }

  int getLevel() => _level;
}
