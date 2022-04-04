import 'dart:collection';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/manager_interface.dart';
import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';

class AdhocManager extends ManagerInterface {
  final TransferManager _manager = TransferManager(true);

  List<ConnectedDevice> _peers = List.empty(growable: true);
  List<AdHocDevice> _discovered = List.empty(growable: true);

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
      for (ConnectedDevice peer in _peers) {
        if (totalPeers.firstWhere((element) => element.id == peer.id,
                orElse: () => null) ==
            null) {
          totalPeers.add(peer);
        }
      }
      data['peers'] = jsonEncode(totalPeers);
      // TODO: Label from plugin is different from own id from uuid
      _manager.broadcastExceptList(
          jsonEncode(data), peersFromMsg.map((e) => e.id).toList());
    } else {
      // Else, add your peers in the message and broadcast it.
      data.putIfAbsent("peers", () => jsonEncode(_peers));
      _manager.broadcast(jsonEncode(data));
    }
  }

  void notifyNewConnection(List<ConnectedDevice> devices) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.indirectConnection.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('connections', () => jsonEncode(devices));
    message.putIfAbsent('peers', () => jsonEncode(_peers));
    _manager.broadcast(jsonEncode(message));
  }

  void startGame(int seed, List<ConnectedDevice> players) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('peers', () => jsonEncode(players));
    message.putIfAbsent('seed', () => seed);
    _manager.broadcast(jsonEncode(message));
  }

  void leaveGroup() {
    if (!this.enabled) return;

    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('peers', () => jsonEncode(_peers));
    _manager.broadcast(jsonEncode(message));

    // Then disconnect
    _manager.disconnectAll();
  }

  void sendNextLevel(bool restart) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendLevelChange.name);
    message.putIfAbsent('restart', () => restart);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('peers', () => jsonEncode(_peers));
    _manager.broadcast(jsonEncode(message));
  }

  void sendColorTapped(GameColors color) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendColorTapped.name);
    message.putIfAbsent('color', () => color.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('peers', () => jsonEncode(_peers));
    _manager.broadcast(jsonEncode(message));
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
        _discovered.add(event.device);
        _sendMessageStream(MessageType.adhocDiscovered,
            [event.device.name, _macFromAdhocDevice(event.device)]);
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
        _discovered.removeWhere((device) =>
            _macFromAdhocDevice(device) == _macFromAdhocDevice(event.device));
        _peers.add(
            ConnectedDevice(event.device.label, event.device.name, true, true));
        _sendMessageStream(MessageType.adhocConnection,
            [event.device.name, event.device.label]);
        break;
      case AdHocType.onConnectionClosed:
        print("----- onConnectionClosed with device ${event.device.name}");
        _peers.removeWhere((device) => device.id == event.device.label);
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

    // TODO: Check WiFi Direct connect
    await _manager.connect(_discovered
        .firstWhere((device) => _macFromAdhocDevice(device) == peer));
  }

  /// Returns the mac address of the given AdHocDevice.
  String _macFromAdhocDevice(AdHocDevice device) {
    return device.mac.ble == '' ? device.mac.wifi : device.mac.ble;
  }
}
