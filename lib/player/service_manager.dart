import 'dart:async';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/connected_device.dart';

abstract class ServiceManager {
  // ignore: close_sinks
  StreamController streamController = StreamController<Map>.broadcast();
  Stream<Map> stream;

  // ignore: close_sinks
  StreamController connectivityController = StreamController<bool>.broadcast();
  Stream<bool> connectivity;
  bool enabled;

  String id;
  String name;

  ServiceManager(this.id) {
    enabled = false;
    stream = streamController.stream;
    connectivity = connectivityController.stream;
  }

  /// ************  General actions **************/

  /// Enable the manager and sets its name (definite).
  void enable(String name);

  /// Transfer a message to all its peers.
  void transferMessage(Map data);

  /// ************  Main page actions ************/

  /// Notify others that you leave the room.
  void leaveGroup();

  /// Notify others that the game has started.
  void startGame(int seed, List<ConnectedDevice> players);

  /// ************  Game page actions ************/

  /// Notify that the next level has started.
  void sendNextLevel(bool restart);

  /// Notify the color pressed.
  void sendColorTapped(GameColors color);
}
