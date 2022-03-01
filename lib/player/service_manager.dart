import 'dart:async';

import 'package:adhoc_gaming/game/game_constants.dart';

abstract class ServiceManager {
  // ignore: close_sinks
  StreamController streamController = StreamController<Map>();
  Stream stream;

  String id;
  String name;

  ServiceManager(this.id) {
    stream = streamController.stream;
  }

  /// ************  Main page actions ************/

  // Notify others the updated name.
  void setName(String name);

  // Notify others that you leave the room.
  void leaveGroup();

  // Notify others that the game has started.
  void startGame(int seed, List players);

  /// ************  Game page actions ************/

  // Notify that the next level has started.
  void sendNextLevel(bool restart);

  // Notify the color pressed.
  void sendColorTapped(GameColors color);
}
