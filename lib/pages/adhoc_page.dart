import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdhocPage extends StatelessWidget {
  const AdhocPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<PlayerManager>(context).isAdhocEnabled)
      return const Center(child: Text("No Adhoc connection"));

    return Column(children: [
      SizedBox(height: 5),
      // Button discovery
      SizedBox(
        height: 60,
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
      SizedBox(
        height: 60,
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
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.device_unknown),
                          title: Center(child: Text(device.name)),
                          subtitle: Center(child: Text(device.id)),
                        ),
                        TextButton(
                          child: const Text('Connect'),
                          onPressed: () async => player.connectPeer(device.id),
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
