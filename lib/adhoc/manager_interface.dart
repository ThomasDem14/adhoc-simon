import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/service_manager.dart';

abstract class ManagerInterface extends ServiceManager {
  ManagerInterface(String id) : super(id);

  /// Start the discovery process.
  void startDiscovery();

  /// Connect to a peer.
  void connectPeer(ConnectedDevice peer);

  /// Send own uuid to a peer.
  void exchangeUUID(ConnectedDevice peer);
}
