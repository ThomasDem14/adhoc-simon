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

  PlayerInfo _info;
  List<PlayerInfo> _groupPlayers = List.empty(growable: true);

  bool _startGame = false;

  AdhocPlayer() {
    _manager.enableBle(3600);
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;

    _info = new PlayerInfo(master: false);
  }

  // Actions in the main page

  void startDiscovery() => _manager.discovery();

  void connectPeer(AdHocDevice peer) async {
    // Establish connection to the peer
    await _manager.connect(peer);
    _discovered.removeWhere((element) => (element.mac == peer.mac));
    _peers.add(peer);

    // If alone in the group, become the master
    if (_groupPlayers.isEmpty) {
      this._info.master = true;
      _groupPlayers.add(this._info);
    }

    notifyListeners();

    // Send invite to peer
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendInvite);
    message.putIfAbsent('players', () => jsonEncode(_groupPlayers));
    _manager.sendMessageTo(message, peer.label);
  }

  void startGame() {
    if (!_info.master)
      return;

    _startGame = true;
    notifyListeners();

    // Only the master can start the game
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame);
    message.putIfAbsent('players', () => jsonEncode(_groupPlayers));
    _manager.broadcast(message);
  }

  void leaveGroup() {
    _groupPlayers = List.empty(growable: true);
    notifyListeners();

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup);
    message.putIfAbsent('player', () => this._info.toJson().toString());
    _manager.broadcast(message);
  }

  void sendReady() {

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
          if (!_discovered.any((element) => element.mac == (discovered as AdHocDevice).mac))
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
      case MessageType.sendInvite:
        // Get players in the group and add yourself in
        _groupPlayers = jsonDecode(data['players']);
        this._info.master = false;
        _groupPlayers.add(this._info);
        notifyListeners();
        // Send accept invite
        var message = HashMap<String, dynamic>();
        message.putIfAbsent('type', () => MessageType.acceptInvite);
        message.putIfAbsent('info', () => _info.toJson().toString());
        _manager.sendMessageTo(message, event.device.label);
        break;

      case MessageType.acceptInvite:
        // Add new player to the group
        _groupPlayers.add(data['info']);
        notifyListeners();
        // Send info to everyone
        var message = HashMap<String, dynamic>();
        message.putIfAbsent('type', () => MessageType.updatePlayers);
        message.putIfAbsent('players', () => jsonEncode(_groupPlayers));
        _manager.broadcastExcept(message, event.device);
        break;

      case MessageType.updatePlayers:
        _groupPlayers = jsonDecode(data['players']);
        notifyListeners();
        break;

      case MessageType.startGame:
        _startGame = true;
        notifyListeners();
        break;

      case MessageType.leaveGroup:
        var player = jsonDecode(data['player']);
        _groupPlayers.removeWhere((element) => element.uuid == player.uuid);
        notifyListeners();
        break;
    }
  }

  /* Getters & setters */

  PlayerInfo getPlayerInfo() => _info;

  String getName() => _info.name ?? "";
  void setName(String name) => _info.name = name;

  bool getMaster() => _info.master;
  bool hasGameStarted() => _startGame;

  List<AdHocDevice> getDiscoveredDevices() => _discovered;
  List<PlayerInfo> getPlayers() => _groupPlayers;
}
