import 'dart:math';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  static final Random random = new Random();

  int _level = 0;
  int _nbPlayers;

  // The sequence consists of a sequence of colors per player
  List<List<GameColors>> _sequence;
  List<GameColors> _currentSequence;

  SimonGame(int nbPlayers) {
    _nbPlayers = nbPlayers;

    // Generate a new empty list for each player
    _sequence =
        new List.generate(nbPlayers, (index) => new List.empty(growable: true));

    _currentSequence =
        new List.generate(_nbPlayers, (index) => GameColors.Default);
  }

  GameColors _randomColor() {
    return GameColors.values[random.nextInt(GameColors.values.length - 1)];
  }

  void startLevel() {
    // if duration is active => return

    // Add 1 new color for each player
    for (var i = 0; i < _nbPlayers; i++)
      _sequence.elementAt(i).add(_randomColor());
    // Increment level
    _level++;

    notifyListeners();

    // Start playing sequence
    _playSequence(0);
  }

  void _playSequence(int turn) {
    if (turn >= _level) return;

    for (var i = 0; i < _nbPlayers; i++) {
      Future.delayed(Duration(seconds: i), () {
        _resetCurrentSequence();
        // Set current color
        var playerSequence = _sequence.elementAt(i);
        _currentSequence[i] = playerSequence.elementAt(turn);
        notifyListeners();
      });
    }

    // Prepare next turn
    Future.delayed(Duration(seconds: _nbPlayers), () {
      _resetCurrentSequence();
      notifyListeners();
      _playSequence(turn + 1);
    });
  }

  void _resetCurrentSequence() => _currentSequence =
      new List.generate(_nbPlayers, (index) => GameColors.Default);

  List<GameColors> getColorSequence() => _currentSequence;

  int getLevel() => _level;
}
