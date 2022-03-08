import 'dart:async';
import 'dart:convert';

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
  StreamSubscription _adhocManagerSubscription;
  FirebaseManager _firebaseManager;
  StreamSubscription _firebaseManagerSubscription;

  List<AdHocDevice> _discovered = List.empty(growable: true);
  List<ConnectedDevice> _peers = List.empty(growable: true);

  // ignore: close_sinks
  StreamController _startGameStreamController =
      StreamController<int>.broadcast();
  Stream startGameStream;

  // ignore: close_sinks
  StreamController _levelGameStreamController =
      StreamController<bool>.broadcast();
  Stream levelGameStream;

  // ignore: close_sinks
  StreamController _colorStreamController =
      StreamController<GameColors>.broadcast();
  Stream colorStream;

  PlayerManager() {
    // Initialize the unique id to represent yourself
    _id = _uuid.v4();
    _adhocManager = AdhocManager(_id);
    _firebaseManager = FirebaseManager(_id);

    // Set up the exposed streams
    startGameStream = _startGameStreamController.stream;
    levelGameStream = _levelGameStreamController.stream;
    colorStream = _colorStreamController.stream;

    // Listen to streams of the managers
    _adhocManager.connectivity.listen((enabled) {
      if (enabled) {
        _adhocManagerSubscription = _adhocManager.stream.listen((data) {
          _processData(data);
        });
      } else {
        _adhocManagerSubscription.cancel();
      }
      notifyListeners();
    });

    _firebaseManager.connectivity.listen((enabled) {
      if (enabled) {
        print('[FirebaseManager] Start listening');
        _firebaseManagerSubscription = _firebaseManager.stream.listen((data) {
          _processData(data);
        });
      } else {
        print('[FirebaseManager] Stop listening');
        _firebaseManagerSubscription.cancel();
      }
      notifyListeners();
    });
  }

  void startGame(int seed) {
    // Add yourself in the list of peers
    _peers.add(ConnectedDevice(_id, false, _name, null));

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
    notifyListeners();
  }

  void _processData(Map data) {
    MessageType type = getMessageTypeFromString(data['type'] as String);
    switch (type) {
      case MessageType.adhocDiscovered:
        var discovered = data['data'] as AdHocDevice;
        // Check for duplicate
        var duplicate = _discovered.firstWhere(
            (element) => discovered.type == 0
                ? element.mac.wifi == discovered.mac.wifi
                : element.mac.ble == discovered.mac.ble,
            orElse: () => null);
        if (duplicate == null) _discovered.add(discovered);
        notifyListeners();
        break;

      case MessageType.adhocConnection:
        var peer = data['data'] as AdHocDevice;
        _discovered.removeWhere((element) => element.name == peer.name);
        _peers.add(ConnectedDevice(data['id'], true, null, peer));
        notifyListeners();
        break;

      case MessageType.firebaseConnection:
        var peer = ConnectedDevice(data['id'], false, data["name"], null);
        // Check for duplicate
        var duplicate = _peers.firstWhere(
            (element) => peer.uuid == element.uuid,
            orElse: () => null);
        if (duplicate == null) _peers.add(peer);
        notifyListeners();
        break;

      case MessageType.startGame:
        var seed = data['seed'] as int;
        var json = jsonDecode(data['players'] as String) as List;
        _peers = json.map((p) => ConnectedDevice.fromJson(p)).toList();
        _startGameStreamController.add(seed);
        break;

      case MessageType.leaveGroup:
        _peers.removeWhere((device) => device.uuid == data['id']);
        notifyListeners();
        break;

      case MessageType.changeName:
        var index = _peers.indexWhere((element) => element.uuid == data['id']);
        if (index >= 0) _peers[index].name = data['name'] as String;
        notifyListeners();
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
  List<AdHocDevice> getDiscoveredDevices() => _discovered;
  List<ConnectedDevice> getPeeredDevices() => _peers;
  int getNbPlayers() => _peers.length;
  String getRoomId() => _firebaseManager.getRoomId();
  bool isFirebaseEnabled() => _firebaseManager.enabled;
  bool isAdhocEnabled() => _adhocManager.enabled;
}
