import 'package:adhoc_gaming/model/game_constants.dart';

class GameConfig {
  double _maxPlayers = 4.0;
  GameType _gameType = GameType.coop;

  GameConfig();

  double getMaxPlayers() => _maxPlayers;
  void setMaxPlayers(double maxPlayers) => _maxPlayers = maxPlayers;

  GameType getGameType() => _gameType;
  void setGameType(GameType type) => _gameType = type;

  Map<String, dynamic> toJson() => {
        'maxPlayers': _maxPlayers,
        'type': _gameType,
      };
}