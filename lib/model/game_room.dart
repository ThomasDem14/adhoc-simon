import 'package:adhoc_gaming/model/game_config.dart';
import 'package:adhoc_gaming/model/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GameRoom extends ChangeNotifier {
  String _roomId;
  GameConfig _config;
  
  List<Uuid> _playerList;

  GameRoom() {
    _config = GameConfig();
    _roomId = Uuid().v4();
  }

  double getMaxPlayers() => _config.getMaxPlayers();
  void setMaxPlayers(double maxPlayers) {
    _config.setMaxPlayers(maxPlayers);
    notifyListeners();
  }

  GameType getGameType() => _config.getGameType();
  void setGameType(GameType type) {
    _config.setGameType(type);
    notifyListeners();
  }

  String getUuid() => _roomId;
  String configToJson() => _config.toJson().toString();
}
