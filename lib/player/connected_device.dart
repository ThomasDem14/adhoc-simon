import 'package:adhoc_plugin/adhoc_plugin.dart';

class ConnectedDevice {
  String uuid;
  AdHocDevice adHocDevice;
  String name;
  bool isAdhoc;

  ConnectedDevice(
      String uuid, bool isAdhoc, String name, AdHocDevice adHocDevice) {
    this.uuid = uuid;
    this.isAdhoc = isAdhoc;
    if (isAdhoc) {
      this.adHocDevice = adHocDevice;
      this.name = name ?? adHocDevice?.name;
    } else {
      this.name = name;
    }
  }
}
