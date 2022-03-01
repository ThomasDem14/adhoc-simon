import 'dart:collection';

import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';

class AdhocManager extends ServiceManager {
  final TransferManager _manager = TransferManager(true);

  AdhocManager(id) : super(id) {
    _manager.enableBle(3600);
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;
  }

  ///******** ServiceManager functions ********/

  void setName(String name) {
    this.name = name;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.changeName.name);
    message.putIfAbsent('name', () => name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);
  }

  void startGame(int seed, List players) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('players', () => players);
    message.putIfAbsent('seed', () => seed);
    _manager.broadcast(message);
  }

  void leaveGroup() {
    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup.name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);

    // Then disconnect
    _manager.disconnectAll();
  }

  void sendNextLevel(bool restart) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendLevelChange.name);
    message.putIfAbsent('restart', () => restart);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);
  }

  void sendColorTapped(GameColors color) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendColorTapped.name);
    message.putIfAbsent('color', () => color.name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(message);
  }

  ///******** Specific to AdhocManager ********/

  // Process messages received
  void _processAdHocEvent(Event event) {
    switch (event.type) {
      case AdHocType.onDeviceDiscovered:
        print("----- onDeviceDiscovered");
        _sendMessageStream(MessageType.adhocDiscovered, event.device);
        break;
      case AdHocType.onDiscoveryStarted:
        print("----- onDiscoveryStarted");
        break;
      case AdHocType.onDiscoveryCompleted:
        print("----- onDiscoveryCompleted");
        break;
      case AdHocType.onDataReceived:
        print("----- onDataReceived");
        streamController.add(event.data);
        break;
      case AdHocType.onForwardData:
        print("----- onForwardData");
        streamController.add(event.data);
        break;
      case AdHocType.onConnection:
        print("----- onConnection with device ${event.device.name}");
        _sendMessageStream(MessageType.adhocConnection, event.device);
        break;
      case AdHocType.onConnectionClosed:
        print("----- onConnectionClosed with device ${event.device.name}");
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

  // Send a message with type and data into the stream.
  void _sendMessageStream(MessageType type, Object data) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => type);
    message.putIfAbsent('data', () => data);
    message.putIfAbsent('id', () => id);
    streamController.add(message);
  }

  // Start the adhoc discover process
  void startDiscovery() {
    _manager.discovery();
  }

  // Establish connection to the peer
  void connectPeer(AdHocDevice peer) async {
    await _manager.connect(peer);
  }
}
