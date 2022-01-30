import 'dart:async';

import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:adhoc_gaming/pages/game_page.dart';
import 'package:adhoc_gaming/pages/transition_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final textController = TextEditingController();
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Provider.of<AdhocPlayer>(context, listen: false)
        .startGameStream
        .listen((event) {
      if (!event) return;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => SimonGame(
                Provider.of<AdhocPlayer>(context, listen: false)
                    .getNbPlayers()),
            child: GamePage(),
          ),
        ));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => TransitionDialog()));
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        // Available players
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black)),
            ),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 0),
                      textStyle: TextStyle(color: Colors.white),
                      primary: Colors.blue,
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
                                  onPressed: () async =>
                                      player.connectPeer(device),
                                ),
                              ],
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
        // Players in your group
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black)),
            ),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 0),
                      textStyle: TextStyle(color: Colors.white),
                      primary: Colors.blue,
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
                      var peers = player.getPeeredDevices();
                      return ListView.builder(
                        padding: EdgeInsets.all(5.0),
                        itemCount: peers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.person),
                                  title: Center(
                                      child: Text(peers.elementAt(index).name)),
                                  subtitle: Center(
                                      child: Text(player.getPlayerName(
                                          peers.elementAt(index).label))),
                                ),
                              ],
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
