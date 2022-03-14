import 'dart:async';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/nearby_manager.dart';
import 'package:adhoc_gaming/firebase/firebase_manager.dart';
import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PlayerManager extends ChangeNotifier {
  Uuid _uuid = Uuid();
  String _id;
  String _name;
  bool _enabled = false;

  NearbyManager _adhocManager;
  StreamSubscription _adhocManagerSubscription;
  FirebaseManager _firebaseManager;
  StreamSubscription _firebaseManagerSubscription;

  List<ConnectedDevice> _discovered = List.empty(growable: true);
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
    _adhocManager = NearbyManager(_id);
    _firebaseManager = FirebaseManager(_id);

    // Set up the exposed streams
    startGameStream = _startGameStreamController.stream;
    levelGameStream = _levelGameStreamController.stream;
    colorStream = _colorStreamController.stream;

    // Listen to streams of the managers
    _adhocManager.connectivity.listen((enabled) {
      if (enabled) {
        print('[NearbyManager] Start listening');
        _adhocManagerSubscription = _adhocManager.stream.listen((data) {
          _processData(data);
        });
      } else {
        print('[NearbyManager] Stop listening');
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

  void enable(String name) {
    if (_enabled) return;

    _name = name;
    _enabled = true;
    // Enable managers
    _adhocManager.enable(name);
    _firebaseManager.enable(name);
  }

  void startGame(int seed) {
    // Add yourself in the list of peers
    _peers.add(ConnectedDevice(
      _id,
      false,
      _name,
    ));

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

  void startDiscovery() {
    _adhocManager.startDiscovery();
  }

  void connectPeer(String endpoint) async {
    _adhocManager.connectPeer(endpoint);
  }

  void connectRoom(String roomId) async {
    _firebaseManager.connectRoom(roomId);
    notifyListeners();
  }

  void _processData(Map data) {
    MessageType type = getMessageTypeFromString(data['type'] as String);
    switch (type) {
      case MessageType.adhocDiscovered:
        var endpoint = data['data'] as List<String>;
        // Check for duplicate
        var duplicate = _discovered.firstWhere(
            (element) => endpoint[1] == element.id,
            orElse: () => null);
        if (duplicate == null)
          _discovered.add(ConnectedDevice(endpoint[1], true, endpoint[0]));
        notifyListeners();
        break;

      case MessageType.adhocConnection:
        var peer = data['data'] as String;
        _discovered.removeWhere((element) => element.name == peer);
        _peers.add(ConnectedDevice(peer, true, peer));
        notifyListeners();
        break;

      case MessageType.firebaseConnection:
        var peer = ConnectedDevice(data['id'], false, data["name"]);
        // Check for duplicate
        var duplicate = _peers.firstWhere((element) => peer.id == element.id,
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
        _peers.removeWhere((device) => device.id == data['id']);
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
  List<ConnectedDevice> getDiscoveredDevices() => _discovered;
  List<ConnectedDevice> getPeeredDevices() => _peers;
  int get nbPlayers => _peers.length;
  String get roomId => _firebaseManager.getRoomId();
  bool get isFirebaseEnabled => _firebaseManager.enabled;
  bool get isAdhocEnabled => _adhocManager.enabled;
  bool get enabled => _enabled;
}
