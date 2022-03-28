import 'dart:collection';
import 'dart:convert';

import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';

class AdhocManager extends ServiceManager {
  final TransferManager _manager = TransferManager(true);

  List<AdHocDevice> _peers = List.empty(growable: true);

  AdhocManager(id) : super(id);

  ///******** ServiceManager functions ********/

  void enable(String name) {
    this.name = name;

    _manager.enable();
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;

    if (_manager.isBluetoothEnabled() || _manager.isWifiEnabled()) {
      // If it was disabled, enable.
      if (!this.enabled) {
        print('[AdhocManager] Enabled');
        this.enabled = true;
        connectivityController.add(true);
      }
    } else {
      // If it was enabled, disable.
      if (this.enabled) {
        print('[AdhocManager] Disabled');
        this.enabled = false;
        connectivityController.add(false);
      }
    }
  }

  void dispose() {
    _manager.disconnectAll();
  }

  void transferMessage(Map data) {
    if (!this.enabled) return;

    // If there is already a set of peers in the message,
    if (data['peers'] != null) {
      // get list of peers..
      var json = jsonDecode(data['peers'] as String) as List;
      var peersFromMsg = json.map((p) => ConnectedDevice.fromJson(p)).toList();
      var totalPeers = List<ConnectedDevice>.from(peersFromMsg);
      // .. and add yours.
      for (AdHocDevice peer in _peers) {
        if (totalPeers.firstWhere((element) => element.id == peer.label,
                orElse: () => null) ==
            null) {
          totalPeers.add(ConnectedDevice(peer.label, true, peer.name));
        }
      }
      data['peers'] = jsonEncode(totalPeers);
      _manager.broadcastExceptList(
          jsonEncode(data), peersFromMsg.map((e) => e.id).toList());
    } else {
      // Else, add your peers in the message and broadcast it.
      data.putIfAbsent("peers", () => jsonEncode(_peers));
      _manager.broadcast(jsonEncode(data));
    }
  }

  void startGame(int seed, List<ConnectedDevice> players) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('players', () => jsonEncode(players));
    message.putIfAbsent('seed', () => seed);
    _manager.broadcast(message);
  }

  void leaveGroup() {
    if (!this.enabled) return;

    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup.name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);

    // Then disconnect
    _manager.disconnectAll();
  }

  void sendNextLevel(bool restart) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendLevelChange.name);
    message.putIfAbsent('restart', () => restart);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);
  }

  void sendColorTapped(GameColors color) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendColorTapped.name);
    message.putIfAbsent('color', () => color.name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);
  }

  ///******** Specific to AdhocManager ********/

  /// Process messages received
  void _processAdHocEvent(Event event) {
    switch (event.type) {
      case AdHocType.onDiscoveryStarted:
        print("----- onDiscoveryStarted");
        break;
      case AdHocType.onDeviceDiscovered:
        print("----- onDeviceDiscovered");
        _sendMessageStream(MessageType.adhocDiscovered,
            [event.device.name, event.device.label]);
        break;
      case AdHocType.onDiscoveryCompleted:
        print("----- onDiscoveryCompleted");
        break;
      case AdHocType.onDataReceived:
        print("----- onDataReceived");
        _processMsgReceived(event);
        break;
      case AdHocType.onForwardData:
        print("----- onForwardData");
        _processMsgReceived(event);
        break;
      case AdHocType.onConnection:
        print("----- onConnection with device ${event.device.name}");
        _peers.add(event.device);
        _sendMessageStream(MessageType.adhocConnection, event.device.label);
        break;
      case AdHocType.onConnectionClosed:
        print("----- onConnectionClosed with device ${event.device.name}");
        _peers.removeWhere((device) => device.label == event.device.label);
        _sendMessageStream(
            MessageType.adhocConnectionEnded, event.device.label);
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

  /// Send a message with type and data into the stream.
  void _sendMessageStream(MessageType type, Object data) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => type.name);
    message.putIfAbsent('data', () => data);
    message.putIfAbsent('id', () => id);
    streamController.add(message);
  }

  void _processMsgReceived(Event message) {
    print(message.data);
    streamController.add(jsonDecode(message.data) as Map);
  }

  /// Start the adhoc discover process
  void startDiscovery() {
    if (!this.enabled) return;

    _manager.discovery();
  }

  /// Establish connection to the peer
  void connectPeer(String peer) async {
    if (!this.enabled) return;

    await _manager.connect(_peers.firstWhere((device) => device.label == peer));
  }
}
