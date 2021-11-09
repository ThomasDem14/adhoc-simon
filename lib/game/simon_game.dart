import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  List<GameColors> _sequence = List.empty(growable: true);
  int _level = 1;

  SimonGame();

  void incrementLevel() {
    _level++;
    notifyListeners();
  }
  int getLevel() => _level;
}