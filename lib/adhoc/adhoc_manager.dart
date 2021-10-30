import 'dart:collection';

import 'package:adhoc_gaming/adhoc/adhoc_constants.dart';
import 'package:adhoc_plugin/adhoc_plugin.dart';

class AdhocManager {
  final TransferManager _manager = TransferManager(true);
  final List<AdHocDevice> _discovered = List.empty(growable: true);
  final List<AdHocDevice> _peers = List.empty(growable: true);

  AdhocManager() {
    _manager.enableBle(3600);
    _manager.eventStream.listen(_processAdHocEvent);
    _manager.open = true;
  }

  void _processAdHocEvent(Event event) {
    switch (event.type) {
      case AdHocType.onDeviceDiscovered:
        break;
      case AdHocType.onDiscoveryStarted:
        break;
      case AdHocType.onDiscoveryCompleted:
        break;
      case AdHocType.onDataReceived:
        _processDataReceived(event);
        break;
      case AdHocType.onForwardData:
        _processDataReceived(event);
        break;
      case AdHocType.onConnection:
        break;
      case AdHocType.onConnectionClosed:
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
      case MessageType.advertiseGroup:

        break;
      case MessageType.requestGroup:
        break;
      case MessageType.joinGroup:
        break;
      case MessageType.leaveGroup: 
        break;
    }
  }

  void advertiseRoom(String id, String jsonContent) {
    var message = HashMap<String, dynamic>();
    message.putIfAbsent('type', () => MessageType.advertiseGroup);
    message.putIfAbsent('id', () => id);
    message.putIfAbsent('config', () => jsonContent);

    print(message);

    _manager.broadcast(message);
  }
}