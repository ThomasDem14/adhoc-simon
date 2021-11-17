import 'dart:collection';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/adhoc_constants.dart';
import 'package:adhoc_gaming/adhoc/player_info.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';
import 'package:flutter/material.dart';

class AdhocPlayer extends ChangeNotifier {
  final TransferManager _manager = TransferManager(true);
  List<AdHocDevice> _discovered = List.empty(growable: true);
  List<AdHocDevice> _peers = List.empty(growable: true);

  String _name;
  var _deviceDictionary = HashMap<String, String>();

  bool _startGame = false;

  AdhocPlayer() {
    _manager.enableBle(3600);
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;
  }

  // Actions in the main page

  void startDiscovery() => _manager.discovery();

  void connectPeer(AdHocDevice peer) async {
    // Establish connection to the peer
    try {
      await _manager.connect(peer);
      _discovered.removeWhere((element) => element.label == peer.label);
      _peers.add(peer);
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  void startGame() {
    _startGame = true;
    notifyListeners();

    // Only the master can start the game
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame);
    _manager.broadcast(message);
  }

  void leaveGroup() {
    _startGame = false;
    
    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup);
    _manager.broadcast(message);

    // Then disconnect
    _manager.disconnectAll();
    notifyListeners();
  }

  // Actions in the game page

  // Process messages

  void _processAdHocEvent(Event event) {
    switch (event.type) {
      case AdHocType.onDeviceDiscovered:
        print("onDeviceDiscovered");
        break;
      case AdHocType.onDiscoveryStarted:
        print("onDiscoveryStarted");
        break;
      case AdHocType.onDiscoveryCompleted:
        print("onDiscoveryCompleted");
        for (final discovered in (event.data as Map).values) {
          if (!_discovered
              .any((element) => element.label == (discovered as AdHocDevice).label))
            _discovered.add(discovered as AdHocDevice);
        }
        notifyListeners();
        break;
      case AdHocType.onDataReceived:
        print("onDataReceived");
        _processDataReceived(event);
        break;
      case AdHocType.onForwardData:
        print("onForwardData");
        _processDataReceived(event);
        break;
      case AdHocType.onConnection:
        print("onConnection");
        _peers.add(event.device);
        notifyListeners();
        break;
      case AdHocType.onConnectionClosed:
        print("onConnectionClosed");
        break;
      case AdHocType.onInternalException:
        break;
      case AdHocType.onGroupInfo:
        break;
      case AdHocType.onGroupDataReceived:
        break;
      default:
    }
  }

  void _processDataReceived(Event event) {
    var data = event.data as Map;
    switch (data['type'] as MessageType) {
      case MessageType.startGame:
        _startGame = true;
        notifyListeners();
        break;

      case MessageType.leaveGroup:
        _manager.disconnect(event.device);
        _peers.removeWhere((device) => device.label == event.device.label);
        notifyListeners();
        break;

      case MessageType.changeName:
        var name = jsonDecode(data['name']) as String;
        _deviceDictionary.putIfAbsent(event.device.label, () => name);
        notifyListeners();
        break;
    }
  }

  /* Getters & setters */

  // TO REMOVE
  List<PlayerInfo> getPlayers() => null;

  String getName() => _name ?? "";
  void setName(String name) {
    _name = name;

    // Send invite to peer
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.changeName);
    message.putIfAbsent('name', () => name);
    _manager.broadcast(message);
  }

  bool hasGameStarted() => _startGame;

  List<AdHocDevice> getDiscoveredDevices() => _discovered;
  List<AdHocDevice> getPeeredDevices() => _peers;

  int getNbPlayers() => _peers.length;
}
