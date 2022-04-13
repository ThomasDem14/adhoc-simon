import 'dart:async';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/connected_device.dart';

abstract class ServiceManager {
  static const int NEXT_LEVEL = -1;
  static const int RESTART_GAME = -2;

  // ignore: close_sinks
  StreamController streamController = StreamController<Map>.broadcast();
  late Stream<Map> stream;

  // ignore: close_sinks
  StreamController connectivityController = StreamController<bool>.broadcast();
  late Stream<bool> connectivity;
  late bool enabled;

  String? uuid;
  String? name;

  ServiceManager(this.uuid) {
    enabled = false;
    stream = streamController.stream as Stream<Map>;
    connectivity = connectivityController.stream as Stream<bool>;
  }

  /// ************  General actions **************/

  /// Enable the manager and sets its name (definite).
  void enable(String name);

  /// Cleanly dispose of the manager resources.
  void dispose();

  /// Transfer a message to all its peers.
  void transferMessage(Map data);

  /// Notify a new connection to all peers.
  void notifyNewConnection(List<ConnectedDevice> devices);

  // Notify that a device has disconnected.
  void notifyDisconnected(ConnectedDevice device);

  /// ************  Main page actions ************/

  /// Notify others that you leave the room.
  void leaveGroup();

  /// Notify others that the game has started.
  void startGame(int seed);

  /// ************  Game page actions ************/

  /// Notify that the next level has started.
  void sendNextLevel(int restart);

  /// Notify the color pressed.
  void sendColorTapped(GameColors color);
}
