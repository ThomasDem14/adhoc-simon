import 'dart:collection';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/adhoc_constants.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';
import 'package:flutter/material.dart';

class AdhocPlayer extends ChangeNotifier {
  final TransferManager _manager = TransferManager(true);
  List<AdHocDevice> _discovered = List.empty(growable: true);
  List<AdHocDevice> _peers = List.empty(growable: true);

  String _name;
  var _deviceDictionary = Map<String, String>();

  bool _startGame = false;

  static const bool _DEBUG = true;

  AdhocPlayer() {
    _manager.enableBle(3600);
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;
  }

  // Actions in the main page

  void startDiscovery() => _manager.discovery();

  void connectPeer(AdHocDevice peer) async {
    // Establish connection to the peer
    await _manager.connect(peer);
    _discovered.removeWhere((element) => element.label == peer.label);
    _peers.add(peer);

    notifyListeners();
  }

  void startGame() {
    _startGame = true;
    notifyListeners();

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame.name);
    message.putIfAbsent('peers', () => _peers);
    _manager.broadcast(message);
  }

  void leaveGroup() {
    _startGame = false;

    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup.name);
    message.putIfAbsent('peers', () => _peers);
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
        print("----- onDeviceDiscovered");
        break;
      case AdHocType.onDiscoveryStarted:
        print("----- onDiscoveryStarted");
        break;
      case AdHocType.onDiscoveryCompleted:
        print("----- onDiscoveryCompleted");
        for (final discovered in (event.data as Map).values) {
          if (!_discovered.any(
              (element) => element.label == (discovered as AdHocDevice).label))
            _discovered.add(discovered as AdHocDevice);
        }
        notifyListeners();
        break;
      case AdHocType.onDataReceived:
        print("----- onDataReceived");
        _processDataReceived(event);
        break;
      case AdHocType.onForwardData:
        print("----- onForwardData");
        _processDataReceived(event);
        break;
      case AdHocType.onConnection:
        print("----- onConnection with device ${event.device.label}");
        _peers.add(event.device);
        _discovered
            .removeWhere((element) => element.label == event.device.label);
        notifyListeners();
        break;
      case AdHocType.onConnectionClosed:
        print("----- onConnectionClosed with device ${event.device.label}");
        _peers.removeWhere((element) => element.label == event.device.label);
        notifyListeners();
        break;
      case AdHocType.onInternalException:
        print("----- onInternalException");
        break;
      case AdHocType.onGroupInfo:
        print("----- onGroupInfo");
        break;
      case AdHocType.onGroupDataReceived:
        print("----- onGroupDataReceived");
        break;
      default:
    }
  }

  void _processDataReceived(Event event) {
    var data = event.data as Map;
    switch (getMessageTypeFromString(data['type'] as String)) {
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
        _deviceDictionary.update(event.device.label, (value) => name,
            ifAbsent: () =>
                _deviceDictionary.putIfAbsent(event.device.label, () => name));
        notifyListeners();
        break;
    }
  }

  /* Getters & setters */

  String getPlayerName(String label) =>
      _deviceDictionary[label] ?? "Player $label";
  String getName() => _name ?? "";
  void setName(String name) {
    _name = name;
    _deviceDictionary.update(_manager.ownAddress, (value) => name,
        ifAbsent: () =>
            _deviceDictionary.putIfAbsent(_manager.ownAddress, () => name));

    // Send notification to peer
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.changeName.name);
    message.putIfAbsent('peers', () => _peers);
    message.putIfAbsent('name', () => name);
    _manager.broadcast(message);
  }

  bool hasGameStarted() => _startGame;

  List<AdHocDevice> getDiscoveredDevices() => _discovered;
  List<AdHocDevice> getPeeredDevices() => _peers;

  int getNbPlayers() => _DEBUG ? 4 : _peers.length;
}
