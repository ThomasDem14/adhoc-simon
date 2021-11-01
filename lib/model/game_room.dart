import 'package:adhoc_gaming/model/game_config.dart';
import 'package:adhoc_gaming/model/game_constants.dart';
import 'package:adhoc_gaming/model/player_info.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GameRoom extends ChangeNotifier {
  String _roomId;
  GameConfig _config;
  
  List<PlayerInfo> _playerList;

  GameRoom() {
    _roomId = Uuid().v4();
    _config = GameConfig();

    _playerList = [];
  }

  int getMaxPlayers() => _config.getMaxPlayers();
  void setMaxPlayers(int maxPlayers) {
    _config.setMaxPlayers(maxPlayers);
    notifyListeners();
  }

  GameType getGameType() => _config.getGameType();
  void setGameType(GameType type) {
    _config.setGameType(type);
    notifyListeners();
  }

  PlayerInfo getPlayerInfo(int index) => _playerList.elementAt(index);
  void addPlayer(PlayerInfo player) => _playerList.add(player);

  int getNumberPlayers() => _playerList.length;
  String getUuid() => _roomId;
  String configToJson() => _config.toJson().toString();
}
