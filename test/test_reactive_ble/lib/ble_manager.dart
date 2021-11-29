import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleManager extends ChangeNotifier {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> discoveredDevices = List.empty(growable: true);
  final List<DiscoveredDevice> connectedDevices = List.empty(growable: true);

  final String dataToSend = "Secret tunnel!";

  static const serviceUuid = '00000001-0000-1000-8000-00805f9b34fb';
  static const characteristicUuid = '00000002-0000-1000-8000-00805f9b34fb';

  void discovery() {
    flutterReactiveBle.scanForDevices(
        withServices: [], scanMode: ScanMode.balanced).listen((event) {
      if (kDebugMode) {
        print(">> device: " + event.name);
      }
      discoveredDevices.add(event);
      notifyListeners();
    }, onError: (Object error) {
      if (kDebugMode) {
        print(">> error" + error.toString());
      }
    });
  }

  void connect(int index) {
    var discoveredDevice = discoveredDevices.elementAt(index);
    flutterReactiveBle.connectToAdvertisingDevice(
      withServices: [Uuid.parse(serviceUuid)],
      prescanDuration: const Duration(seconds: 5),
      id: discoveredDevice.id,
      connectionTimeout: const Duration(seconds: 2),
    ).listen((state) {
      var id = state.deviceId.toString();
      switch (state.connectionState) {
        case DeviceConnectionState.connecting:
          if (kDebugMode) {
            print(">> Connecting to $id\n");
          }
          break;
        case DeviceConnectionState.connected:
          if (kDebugMode) {
            print(">> Connected to $id\n");
          }
          // Set up listener
          var characteristic = QualifiedCharacteristic(
            serviceId: Uuid.parse(serviceUuid),
            characteristicId: Uuid.parse(characteristicUuid),
            deviceId: state.deviceId,
          );
          flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
            if (kDebugMode) {
              print(">> Received: " + String.fromCharCodes(data));
            }
          });
          // Update lists
          connectedDevices.add(discoveredDevice);
          discoveredDevices.remove(discoveredDevice);
          notifyListeners();
          break;
        case DeviceConnectionState.disconnecting:
          if (kDebugMode) {
            print(">> Disconnecting from $id\n");
          }
          break;
        case DeviceConnectionState.disconnected:
          if (kDebugMode) {
            print(">> Disconnected from $id\n");
          }
          break;
      }
    }, onError: (Object error) {
      if (kDebugMode) {
        print(">> error" + error.toString());
      }
    });
  }

  void send(int index) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse(serviceUuid),
      characteristicId: Uuid.parse(characteristicUuid),
      deviceId: connectedDevices.elementAt(index).id,
    );
    await flutterReactiveBle.writeCharacteristicWithResponse(
      characteristic,
      value: dataToSend.codeUnits,
    );
  }
}
