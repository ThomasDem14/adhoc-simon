import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:adhoc_gaming/pages/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final textController = TextEditingController();

  Widget gameDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('The game has been started'),
      content: const Text('Would you like to join ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Provider.of<AdhocPlayer>(context).leaveGroup();
            Navigator.pop(context, 'Leave');
            Navigator.of(context).pushReplacementNamed('/');
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Provider.of<AdhocPlayer>(context).sendReady();
            Navigator.pop(context, 'Join');
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show alert dialog to notify the slaves that the game started
    if (Provider.of<AdhocPlayer>(context).hasGameStarted()) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => SimonGame(),
          child: GamePage(),
        ),
      ));
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierDismissible: true,
          opaque: false,
          pageBuilder: (context, _, __) => gameDialog(context),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ad Hoc Main Room'),
      ),
      body: Column(children: [
        // You
        Container(
          margin: EdgeInsets.all(10.0),
          child: Consumer<AdhocPlayer>(
            builder: (context, player, child) => TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
              controller: textController,
              onChanged: (text) => player.setName(text),
            ),
          ),
        ),
        // Players in your group
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 0),
                    ),
                    onPressed: Provider.of<AdhocPlayer>(context, listen: false)
                        .startGame,
                    child: const Text("Start game with group"),
                  ),
                ),
                // Player list
                Expanded(
                  flex: 5,
                  child: Consumer<AdhocPlayer>(
                    builder: (context, player, child) {
                      var peers = player.getPlayers();
                      return ListView.builder(
                        padding: EdgeInsets.all(5.0),
                        itemCount: peers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Row(children: [
                              Text(peers.elementAt(index)?.name ?? ""),
                              Container(
                                child: peers.elementAt(index).master
                                    ? Icon(Icons.star)
                                    : Container(),
                              ),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Available players
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 0),
                    ),
                    onPressed: Provider.of<AdhocPlayer>(context, listen: false)
                        .startDiscovery,
                    child: const Text("Search for available players"),
                  ),
                ),
                // Device list
                Expanded(
                  flex: 5,
                  child: Consumer<AdhocPlayer>(
                    builder: (context, player, child) {
                      var devices = player.getDiscoveredDevices();
                      return ListView.builder(
                        padding: EdgeInsets.all(5.0),
                        itemCount: devices.length,
                        itemBuilder: (BuildContext context, int index) {
                          var device = devices.elementAt(index);
                          var type = device.mac.ble == '' ? 'Wi-Fi' : 'BLE';
                          var mac = device.mac.ble == ''
                              ? device.mac.wifi
                              : device.mac.ble;
                          return Card(
                            child: ListTile(
                              title: Center(child: Text(device.name)),
                              subtitle: Center(child: Text('$type: $mac')),
                              onTap: () async => player.connectPeer(device),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
