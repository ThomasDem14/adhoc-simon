import 'dart:async';

import 'package:adhoc_gaming/adhoc/adhoc_manager.dart';
import 'package:adhoc_gaming/firebase/firebase_manager.dart';
import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PlayerManager extends ChangeNotifier {
  Uuid _uuid = Uuid();
  String _id;
  String _name;

  AdhocManager _adhocManager;
  FirebaseManager _firebaseManager;

  List<AdHocDevice> _discovered = List.empty(growable: true);
  List<ConnectedDevice> _peers = List.empty(growable: true);

  // ignore: close_sinks
  StreamController _startGameStreamController = StreamController<int>();
  Stream startGameStream;

  // ignore: close_sinks
  StreamController _levelGameStreamController = StreamController<bool>();
  Stream levelGameStream;

  // ignore: close_sinks
  StreamController _colorStreamController = StreamController<GameColors>();
  Stream colorStream;

  PlayerManager() {
    // Initialize the unique id to represent yourself
    _id = _uuid.v4();
    _adhocManager = AdhocManager(_id);
    _firebaseManager = FirebaseManager(_id);

    // Add yourself in the list of peers
    _peers.add(ConnectedDevice(_id, false, null, null));

    // Set up the exposed streams
    startGameStream = _startGameStreamController.stream;
    levelGameStream = _levelGameStreamController.stream;
    colorStream = _colorStreamController.stream;

    // Listen to streams of the managers
    _adhocManager.stream.listen((data) {
      _processData(data);
    });
    _firebaseManager.stream.listen((data) {
      _processData(data);
    });
  }

  void startGame(int seed) {
    _adhocManager.startGame(seed, _peers);
    _firebaseManager.startGame(seed, _peers);

    _startGameStreamController.add(seed);
  }

  void leaveGroup() {
    _adhocManager.leaveGroup();
    _firebaseManager.leaveGroup();

    _discovered = List.empty(growable: true);
    _peers = List.empty(growable: true);
    notifyListeners();
  }

  void sendNextLevel(bool restart) {
    _adhocManager.sendNextLevel(restart);
    _firebaseManager.sendNextLevel(restart);

    _levelGameStreamController.add(restart);
  }

  void sendColorTapped(GameColors color) {
    _adhocManager.sendColorTapped(color);
    _firebaseManager.sendColorTapped(color);

    _colorStreamController.add(color);
  }

  void setName(String name) {
    _name = name;

    // Update in the list of peers as well.
    var index = _peers.indexWhere((element) => element.uuid == _id);
    _peers[index].name = name;

    _adhocManager.setName(name);
    _firebaseManager.setName(name);
  }

  void startDiscovery() {
    _adhocManager.startDiscovery();
  }

  void connectPeer(AdHocDevice peer) async {
    _adhocManager.connectPeer(peer);
  }

  void connectRoom(String roomId) async {
    _firebaseManager.connectRoom(roomId);
  }

  void _processData(Map data) {
    MessageType type = getMessageTypeFromString(data['type'] as String);
    switch (type) {
      case MessageType.adhocDiscovered:
        _discovered.add(data['data']);
        break;

      case MessageType.adhocConnection:
        var peer = data['data'] as AdHocDevice;
        _discovered.removeWhere((element) => element.name == peer.name);
        _peers.add(ConnectedDevice(data['id'], true, null, peer));
        break;

      case MessageType.firebaseConnection:
        _peers.add(ConnectedDevice(data['id'], false, data["name"], null));
        break;

      case MessageType.startGame:
        var seed = data['seed'] as int;
        var list = data['players'] as List<dynamic>;
        // TODO
        _startGameStreamController.add(seed);
        break;

      case MessageType.leaveGroup:
        _peers.removeWhere((device) => device.uuid == data['id']);
        break;

      case MessageType.changeName:
        var index = _peers.indexWhere((element) => element.uuid == data['id']);
        _peers[index].name = data['name'] as String;
        break;

      case MessageType.sendColorTapped:
        var color = data['color'] as String;
        _colorStreamController.add(getGameColorsFromString(color));
        break;

      case MessageType.sendLevelChange:
        var restart = data['restart'] as bool;
        _levelGameStreamController.add(restart);
        break;
    }
  }

  // Getters
  String getName() => _name ?? "You";
  List<AdHocDevice> getDiscoveredDevices() => _discovered;
  List<ConnectedDevice> getPeeredDevices() => _peers;
  int getNbPlayers() => _peers.length;
}