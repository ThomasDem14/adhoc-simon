import 'dart:async';

import 'package:adhoc_gaming/adhoc/adhoc_manager.dart';
import 'package:flutter/material.dart';

class Player extends ChangeNotifier {
  AdhocManager _manager;

  bool _master = false;
  String _name;

  Timer _timer;

  Player() {
    _manager = new AdhocManager();
    _master = false;
  }

  String getName() => _name;
  void setName(String name) => _name = name;

  bool getMaster() => _master;
  void setMaster(bool master) => _master = master;

  void advertiseRoom(String roomId, String jsonContent) {
    _manager.advertiseRoom(roomId, jsonContent);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _manager.advertiseRoom(roomId, jsonContent);
    });
  }
  void leaveRoom() => _timer?.cancel();
}