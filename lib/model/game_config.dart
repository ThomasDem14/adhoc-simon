import 'package:adhoc_gaming/model/game_constants.dart';

class GameConfig {
  int _maxPlayers = 4;
  int _numberPlayers = 0;
  GameType _gameType = GameType.coop;

  GameConfig();

  int getMaxPlayers() => _maxPlayers;
  void setMaxPlayers(int maxPlayers) => _maxPlayers = maxPlayers;

  int getNumberPlayers() => _numberPlayers;
  void addPlayer() => _numberPlayers++;

  GameType getGameType() => _gameType;
  void setGameType(GameType type) => _gameType = type;

  Map<String, dynamic> toJson() => {
        'maxPlayers': _maxPlayers,
        'type': _gameType,
      };
}