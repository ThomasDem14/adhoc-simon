import 'dart:math';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';

class SimonGame extends ChangeNotifier {
  late int _seed;
  late Random _random;

  int _nbPlayers;

  int _level = 0;
  int _turnSequence = 0;
  int _turnWaiting = 0;
  int _nbColors = 0;

  bool _isPlayingSequence = false;
  bool _isWaitingForInput = false;

  bool _gameOver = false;

  // The sequence consists of colors
  late List<GameColors> _currentSequence;
  GameColors _lastInput = GameColors.Default;

  SimonGame(this._nbPlayers, this._seed) {
    // Generate a new empty sequence
    _currentSequence = new List.empty(growable: true);

    // Define the instance of random with given seed
    _random = new Random(_seed);
  }

  /// Returns a random color from the enum list.
  GameColors _randomColor() {
    return GameColors.values[_random.nextInt(GameColors.values.length - 1)];
  }

  /// Restart with a new number of players
  void reset(int players) {
    _nbPlayers = players;
    restart();
  }

  /// Reset the default settings.
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

  /// Add new colors in the sequence and play it after to start the level.
  void startLevel() {
    // if duration is active => return
    if (_isPlayingSequence) return;

    _lastInput = GameColors.Default;

    // Add 1 new color for each player
    _nbColors += _nbPlayers;
    for (var i = 0; i < _nbPlayers; i++) {
      _currentSequence.add(_randomColor());
      _currentSequence.add(GameColors.Default);
    }

    // Increment level
    _level++;
    notifyListeners();

    // Start playing sequence
    _playSequence();
  }

  /// Defines the process to play the color sequence.
  void _playSequence() {
    _isPlayingSequence = true;
    for (var i = 0; i <= _nbColors; i++) {
      // 0.7 Second of the color
      Future.delayed(Duration(milliseconds: i * 1000), () {
        // Set current turn
        _turnSequence = 2 * i;
        notifyListeners();
      });
      // 0.3 Second of black
      Future.delayed(Duration(milliseconds: i * 1000 + 700), () {
        _turnSequence = 2 * i + 1;

        // End of the sequence
        if (i == _nbColors) {
          _isPlayingSequence = false;
          _isWaitingForInput = true;
          _turnWaiting = 0;
          _turnSequence = 0;
        }

        notifyListeners();
      });
    }
  }

  /// Returns the color that should be displayed at the current time.
  GameColors getCurrentColor() {
    if (_isPlayingSequence) return _getColor(_turnSequence);

    return _lastInput;
  }

  /// Returns the color in the sequence at the specific turn.
  GameColors _getColor(int turn) {
    if (turn >= 2 * _nbColors) return GameColors.Default;

    return _currentSequence.elementAt(turn);
  }

  /// Check if the received input matches the sequence.
  void processInput(GameColors color) {
    _lastInput = color;

    if (_getColor(2 * _turnWaiting) == color) {
      _turnWaiting++;

      // End of the sequence
      if (_turnWaiting >= _nbColors) {
        _isWaitingForInput = false;
        _turnWaiting = 0;
      }

      notifyListeners();
      return;
    }

    // Game over at the first fail
    _gameOver = true;
    _isWaitingForInput = false;
    notifyListeners();
  }

  int getPlayerTurn() => _turnWaiting % _nbPlayers;
  bool isPlayingSequence() => _isPlayingSequence;
  bool isWaitingForInput() => _isWaitingForInput;
  bool isGameOver() => _gameOver;
  int getLevel() => _level;
  int getNumberPlayers() => _nbPlayers;
}
