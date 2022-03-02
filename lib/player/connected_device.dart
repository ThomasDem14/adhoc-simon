import 'package:adhoc_plugin/adhoc_plugin.dart';

class ConnectedDevice {
  String uuid;
  bool isAdhoc;
  String name;
  AdHocDevice adHocDevice;

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

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      json['uuid'],
      json['isAdhoc'],
      json['name'],
      json['adHocDevice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'isAdhoc': isAdhoc,
        'name': name,
        'adHocDevice': adHocDevice,
      };
}
