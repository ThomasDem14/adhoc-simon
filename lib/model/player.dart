import 'dart:async';

import 'package:adhoc_gaming/adhoc/adhoc_manager.dart';
import 'package:adhoc_gaming/model/player_info.dart';
import 'package:flutter/material.dart';

class Player extends ChangeNotifier {
  AdhocManager _manager;

  PlayerInfo _info;

  Timer _timer;

  Player() {
    _manager = new AdhocManager();
    _info = new PlayerInfo(master: false);
  }

  PlayerInfo getPlayerInfo() => _info;

  String getName() => _info.name;
  void setName(String name) => _info.name = name;

  bool getMaster() => _info.master;
  void setMaster(bool master) => _info.master = master;

  void advertiseRoom(String roomId, String jsonContent) {
    _manager.advertiseRoom(roomId, jsonContent);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _manager.advertiseRoom(roomId, jsonContent);
    });
  }
  void leaveRoom() { _timer?.cancel(); print("Stop"); }
}