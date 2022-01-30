import 'dart:math';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  static final Random random = new Random();

  final int _nbPlayers;

  int _level = 0;
  int _turnSequence = 0;
  int _turnWaiting = 0;
  int _nbColors = 0;

  bool _isPlayingSequence = false;
  bool _isWaitingForInput = false;

  bool _gameOver = false;

  // The sequence consists of colors
  List<GameColors> _currentSequence;
  GameColors _lastInput = GameColors.Default;

  SimonGame(this._nbPlayers) {
    // Generate a new empty sequence
    _currentSequence = new List.empty(growable: true);
  }

  GameColors _randomColor() {
    return GameColors.values[random.nextInt(GameColors.values.length - 1)];
  }

  void restart() {
    _level = 0;
    _turnSequence = 0;
    _turnWaiting = 0;
    _nbColors = 0;

    _isPlayingSequence = false;
    _isWaitingForInput = false;

    _gameOver = false;

    _currentSequence = new List.empty(growable: true);
    _lastInput = GameColors.Default;

    notifyListeners();
  }

  void startLevel() {
    // if duration is active => return
    if (_isPlayingSequence || _isWaitingForInput) return;

    _lastInput = GameColors.Default;

    // Add 1 new color for each player
    _nbColors += _nbPlayers;
    for (var i = 0; i < _nbPlayers; i++) _currentSequence.add(_randomColor());

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
        _turnSequence = i;

        if (i == _nbColors) {
          _isPlayingSequence = false;
          _isWaitingForInput = true;
          _turnWaiting = 0;
        }

        notifyListeners();
      });
    }
  }

  GameColors getCurrentColor() {
    if (_isPlayingSequence)
      return _getColor(_turnSequence);

    return _lastInput;
  }

  GameColors _getColor(int turn) {
    if (turn >= _nbColors) return GameColors.Default;

    return _currentSequence.elementAt(turn);
  }

  void processInput(GameColors color) {
    _lastInput = color;

    if (_getColor(_turnWaiting) == color) {
      _turnWaiting++;

      if (_turnWaiting >= _nbColors) {
        _isWaitingForInput = false;
        _turnWaiting = 0;
      }

      notifyListeners();
      return;
    }

    _gameOver = true;
    _isWaitingForInput = false;
    notifyListeners();
  }

  int getPlayerTurn() => _turnSequence % _nbPlayers;
  bool isPlayingSequence() => _isPlayingSequence;
  bool isWaitingForInput() => _isWaitingForInput;
  bool isGameOver() => _gameOver;
  int getLevel() => _level;
}
