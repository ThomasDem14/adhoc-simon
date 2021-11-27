import 'dart:math';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  static final Random random = new Random();

  final int _nbPlayers;
  
  int _level = 0;
  int _turn = 1;
  int _nbColors = 0;

  bool _isPlayingSequence = false;

  // The sequence consists of colors
  List<GameColors> _currentSequence;

  SimonGame(this._nbPlayers) {
    // Generate a new empty sequence
    _currentSequence = new List.empty(growable: true);
  }

  GameColors _randomColor() {
    return GameColors.values[random.nextInt(GameColors.values.length - 1)];
  }

  void startLevel() {
    // if duration is active => return

    // Add 1 new color for each player
    for (var i = 0; i < _nbPlayers; i++) _currentSequence.add(_randomColor());

    _nbColors += _nbPlayers;

    // Increment level
    _level++;

    notifyListeners();

    // Start playing sequence
    _playSequence();
  }

  void _playSequence() {
    _isPlayingSequence = true;
    for (var i = 0; i <= _nbColors; i++) {
      Future.delayed(Duration(seconds: i), () {
        // Set current turn
        _turn = i;

        if (i == _nbColors)
          _isPlayingSequence = false;

        notifyListeners();
      });
    }
  }

  GameColors getCurrentColor() {
    if (_turn >= _nbColors) return GameColors.Default;
    print("get $_turn");
    return _currentSequence.elementAt(_turn);
  }

  int getPlayerTurn() => _turn % _nbPlayers;
  bool isPlayingSequence() => _isPlayingSequence;
  int getLevel() => _level;
}
