import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:nearby_plugin/nearby_plugin.dart';

class NearbyManager extends ServiceManager {
  final TransferManager _manager = TransferManager();

  NearbyManager(id) : super(id);

  ///******** ServiceManager functions ********/

  void enable(String name) {
    this.name = name;
    _manager.enable(this.name);
    _manager.eventStream.listen(_processAdHocEvent);

    print('[NearbyManager] Enabled');
    this.enabled = true;
    connectivityController.add(true);
  }

  void startGame(int seed, List<ConnectedDevice> players) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.startGame.name);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('players', () => jsonEncode(players));
    message.putIfAbsent('seed', () => seed);
    _manager.broadcast(jsonEncode(message));
  }

  void leaveGroup() {
    if (!this.enabled) return;

    // Send leave message
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.leaveGroup.name);
    message.putIfAbsent('id', () => id);
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
    _manager.broadcast(jsonEncode(message));
  }

  void sendColorTapped(GameColors color) {
    if (!this.enabled) return;

    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.sendColorTapped.name);
    message.putIfAbsent('color', () => color.name);
    message.putIfAbsent('id', () => id);
    _manager.broadcast(jsonEncode(message));
  }

  ///******** Specific to AdhocManager ********/

  // Process messages received
  void _processAdHocEvent(NearbyMessage event) {
    switch (event.type) {
      case NearbyMessageType.onDiscoveryStarted:
        print("----- onDiscoveryStarted");
        break;
      case NearbyMessageType.onEndpointDiscovered:
        print("----- onEndpointDiscovered: ${event.endpoint}");
        _sendMessageStream(
            MessageType.adhocDiscovered, [event.endpoint, event.endpointId]);
        break;
      case NearbyMessageType.onDiscoveryEnded:
        print("----- onDiscoveryEnded");
        break;
      case NearbyMessageType.onEndpointLost:
        print("----- onEndpointLost: ${event.endpointId}");
        _sendMessageStream(MessageType.adhocDiscoveredEnded, event.endpointId);
        break;
      case NearbyMessageType.onPayloadReceived:
        print("----- onPayloadReceived");
        _processMsgReceived(event);
        break;
      case NearbyMessageType.onPayloadTransferred:
        print("----- onPayloadTransferred");
        break;
      case NearbyMessageType.onConnectionAccepted:
        print("----- onConnection with device ${event.endpointId}");
        _sendMessageStream(MessageType.adhocConnection, event.endpointId);
        break;
      case NearbyMessageType.onConnectionEnded:
        print("----- onConnectionClosed with device ${event.endpointId}");
        _sendMessageStream(MessageType.adhocConnectionEnded, event.endpointId);
        break;
      default:
    }
  }

  // Send a message with type and data into the stream.
  void _sendMessageStream(MessageType type, Object data) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => type.name);
    message.putIfAbsent('data', () => data);
    message.putIfAbsent('id', () => id);
    streamController.add(message);
  }

  void _processMsgReceived(NearbyMessage message) {
    print(message.payload);
    streamController.add(jsonDecode(message.payload) as Map);
  }

  // Start the adhoc discover process
  void startDiscovery() {
    if (!this.enabled) return;

    _manager.discovery(3600);
  }

  // Establish connection to the peer
  void connectPeer(String peer) {
    if (!this.enabled) return;

    _manager.connect(peer);
  }
}
