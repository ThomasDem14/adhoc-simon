import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdhocPage extends StatelessWidget {
  const AdhocPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Button discovery
      Expanded(
        flex: 1,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed:
              Provider.of<PlayerManager>(context, listen: false).startDiscovery,
          child: const Text("Search for available players"),
        ),
      ),
      SizedBox(height: 5),
      // Button disconnect all
      Expanded(
        flex: 1,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed: () =>
              Provider.of<PlayerManager>(context, listen: false).leaveGroup(),
          child: const Text("Disconnect all"),
        ),
      ),
      SizedBox(height: 5),
      // Device list
      Expanded(
        flex: 7,
        child: Consumer<PlayerManager>(
          builder: (context, player, child) {
            var devices = player.getDiscoveredDevices();
            var peers = player.getPeeredDevices();
            return ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: devices.length + peers.length,
              itemBuilder: (BuildContext context, int index) {
                // Discovered devices
                if (index < devices.length) {
                  var device = devices.elementAt(index);
                  var type = device.mac.ble == '' ? 'Wi-Fi' : 'BLE';
                  var mac =
                      device.mac.ble == '' ? device.mac.wifi : device.mac.ble;
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.device_unknown),
                          title: Center(child: Text(device.name)),
                          subtitle: Center(child: Text('$type: $mac')),
                        ),
                        TextButton(
                          child: const Text('Connect'),
                          onPressed: () async => player.connectPeer(device),
                        ),
                      ],
                    ),
                  );
                }
                // Connected (adhoc only) devices
                else {
                  int i = index - devices.length;
                  var device = peers.elementAt(i);
                  return device.isAdhoc
                      ? Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.person),
                                title: Center(child: Text(device.name)),
                                subtitle: Center(child: Text('Adhoc player')),
                              ),
                              TextButton(
                                child: const Text('Connected'),
                                onPressed: () => {},
                              ),
                            ],
                          ),
                        )
                      : Container();
                }
              },
            );
          },
        ),
      ),
    ]);
  }
}
