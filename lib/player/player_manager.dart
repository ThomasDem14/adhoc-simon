import 'dart:async';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/manager_interface.dart';
import 'package:adhoc_gaming/adhoc/nearby_manager.dart';
import 'package:adhoc_gaming/adhoc/adhoc_manager.dart';
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

  ManagerInterface _adhocManager;
  StreamSubscription _adhocManagerSubscription;
  FirebaseManager _firebaseManager;
  StreamSubscription _firebaseManagerSubscription;

  List<ConnectedDevice> _discovered = List.empty(growable: true);
  List<ConnectedDevice> _peers = List.empty(growable: true);

  // ignore: close_sinks
  StreamController _startGameStreamController =
      StreamController<int>.broadcast();
  Stream<int> startGameStream;

  // ignore: close_sinks
  StreamController _levelGameStreamController =
      StreamController<int>.broadcast();
  Stream<int> levelGameStream;

  // ignore: close_sinks
  StreamController _colorStreamController =
      StreamController<GameColors>.broadcast();
  Stream<GameColors> colorStream;

  /// plugin: 0 for adhoc_plugin & 1 for nearby_plugin
  PlayerManager(String name, int plugin) {
    // Initialize the unique id to represent yourself
    _id = _uuid.v4();
    _name = name;

    if (plugin == 0) {
      _adhocManager = AdhocManager(_id);
    } else {
      _adhocManager = NearbyManager(_id);
    }
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

    // Enable managers
    _adhocManager.enable(name);
    _firebaseManager.enable(name);
    _enabled = true;
  }

  void dispose() {
    _adhocManagerSubscription.cancel();
    _firebaseManagerSubscription.cancel();
    _adhocManager.dispose();
    _firebaseManager.dispose();
    super.dispose();
  }

  void startGame(int seed) {
    // Add yourself in the list of peers
    _peers.add(ConnectedDevice(
      uuid: _id,
      id: null,
      name: _name,
      isAdhoc: true,
      isDirect: true,
    ));

    _adhocManager.startGame(seed);
    _firebaseManager.startGame(seed);

    _startGameStreamController.add(seed);
  }

  void leaveGroup() {
    _adhocManager.leaveGroup();
    _firebaseManager.leaveGroup();

    _discovered = List.empty(growable: true);
    _peers = List.empty(growable: true);
    notifyListeners();
  }

  void sendNextLevel(int restart) {
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

  void connectPeer(ConnectedDevice endpoint) async {
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
        if (duplicate == null) {
          _discovered.add(ConnectedDevice(
              uuid: null,
              id: endpoint[1],
              name: endpoint[0],
              isAdhoc: true,
              isDirect: true));
          notifyListeners();
        }
        break;

      case MessageType.adhocDiscoveredEnded:
        var endpoint = data['data'] as String;
        _discovered.removeWhere((element) => element.id == endpoint);
        notifyListeners();
        break;

      case MessageType.adhocConnection:
        var endpoint = data['data'] as List<String>;
        var device = ConnectedDevice(
            uuid: null,
            id: endpoint[1],
            name: endpoint[0],
            isAdhoc: true,
            isDirect: true);
        _discovered.removeWhere((element) => element.name == device.name);
        notifyListeners();
        _adhocManager.exchangeUUID(device);
        break;

      case MessageType.adhocConnectionEnded:
        var endpoint = data['data'] as String;
        _peers.removeWhere((element) => element.id == endpoint);
        notifyListeners();
        break;

      case MessageType.firebaseConnection:
        var peer = ConnectedDevice(
            uuid: data['uuid'],
            id: data['id'],
            name: data["name"],
            isAdhoc: false,
            isDirect: true);
        // Check for duplicate
        var duplicate = _peers.firstWhere(
            (element) => peer.uuid == element.uuid,
            orElse: () => null);
        if (duplicate == null) {
          _peers.add(peer);
          notifyListeners();
        }
        _adhocManager.notifyNewConnection(_peers);
        break;

      case MessageType.exchangeUUID:
        var peer = ConnectedDevice(
            uuid: data['uuid'],
            id: data['id'],
            name: data["name"],
            isAdhoc: true,
            isDirect: true);
        // Check for duplicate
        var duplicate = _peers.firstWhere(
            (element) => peer.uuid == element.uuid,
            orElse: () => null);
        if (duplicate == null) {
          _peers.add(peer);
          notifyListeners();
        }
        _adhocManager.notifyNewConnection(_peers);
        _firebaseManager.notifyNewConnection(_peers);
        break;

      case MessageType.indirectConnection:
        var json = jsonDecode(data['connections'] as String) as List;
        var devices = json.map((p) => ConnectedDevice.fromJson(p)).toList();

        // Update list of peers with new info
        for (var device in devices) {
          // Check if it is you.
          if (device.uuid == this._id) continue;
          // Check for duplicates.
          var duplicate = _peers.firstWhere(
              (element) => device.uuid == element.uuid,
              orElse: () => null);
          if (duplicate == null) {
            device.isDirect = false;
            _peers.add(device);
          }
        }

        notifyListeners();
        _transferMessage(data);
        break;

      case MessageType.startGame:
        var seed = data['seed'] as int;
        _startGameStreamController.add(seed);
        _transferMessage(data);
        break;

      case MessageType.leaveGroup:
        _peers.removeWhere((device) => device.id == data['id']);
        // Reset the game with a new number of players
        _levelGameStreamController.add(_peers.length);
        notifyListeners();
        _transferMessage(data);
        break;

      case MessageType.sendColorTapped:
        var color = data['color'] as String;
        _colorStreamController.add(getGameColorsFromString(color));
        _transferMessage(data);
        break;

      case MessageType.sendLevelChange:
        var restart = data['restart'] as int;
        _levelGameStreamController.add(restart);
        _transferMessage(data);
        break;
    }
  }

  void _transferMessage(Map data) {
    if (_isMessageFromFirebase(data)) {
      _adhocManager.transferMessage(data);
    } else {
      _adhocManager.transferMessage(data);
      _firebaseManager.transferMessage(data);
    }
  }

  bool _isMessageFromFirebase(Map msg) {
    return msg["peers"] == null;
  }

  // Getters
  List<ConnectedDevice> getDiscoveredDevices() => _discovered;
  List<ConnectedDevice> getPeeredDevices() => _peers;
  int get nbPlayers => _peers.length;
  String get roomId => _firebaseManager.getRoomId();
  String get name => _name;
  bool get isFirebaseEnabled => _firebaseManager.enabled;
  bool get isAdhocEnabled => _adhocManager.enabled;
  bool get enabled => _enabled;
}
