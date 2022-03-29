import 'package:adhoc_gaming/player/service_manager.dart';

abstract class ManagerInterface extends ServiceManager {
  ManagerInterface(String id) : super(id);

  /// Start the discovery process.
  void startDiscovery();

  /// Connect to a peer.
  void connectPeer(String peer);
}
