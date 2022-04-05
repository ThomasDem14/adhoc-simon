import 'dart:collection';
import 'dart:convert';

import 'package:adhoc_gaming/adhoc/manager_interface.dart';
import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:nearby_plugin/nearby_plugin.dart';

class NearbyManager extends ManagerInterface {
  final TransferManager _manager = TransferManager();

  List<ConnectedDevice> _peers = List.empty(growable: true);

  NearbyManager(id) : super(id);

  ///******** ServiceManager functions ********/

  void enable(String name) {
    this.name = name;

    _manager.enable(this.name).then((enabled) {
      if (enabled) {
        _manager.eventStream.listen(_processAdHocEvent);
        print('[NearbyManager] Enabled');
        this.enabled = true;
        connectivityController.add(true);
      } else {
        print('[NearbyManager] Disabled');
        this.enabled = false;
        connectivityController.add(false);
      }
    });
  }

  void dispose() {
    _manager.disable();
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
      // Update list of peers.
      data['peers'] = jsonEncode(totalPeers);
      // Broadcast for all except the peers that already were in the message.
      _manager.broadcastExcept(
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
    message.putIfAbsent('seed', () => seed);
    message.putIfAbsent('peers', () => jsonEncode(_peers));
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
        _peers
            .add(ConnectedDevice(event.endpointId, event.endpoint, true, true));
        _sendMessageStream(
            MessageType.adhocConnection, [event.endpoint, event.endpointId]);
        break;
      case NearbyMessageType.onConnectionEnded:
        print("----- onConnectionClosed with device ${event.endpointId}");
        _peers.removeWhere((element) => element.id == event.endpointId);
        _sendMessageStream(MessageType.adhocConnectionEnded, event.endpointId);
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

  void _processMsgReceived(NearbyMessage message) {
    print(message.payload);
    streamController.add(jsonDecode(jsonEncode(message.payload)) as Map);
  }

  /// Start the adhoc discover process
  void startDiscovery() {
    if (!this.enabled) return;

    _manager.discovery(3600);
  }

  /// Establish connection to the peer
  void connectPeer(String peer) {
    if (!this.enabled) return;

    _manager.connect(peer);
  }
}
