import 'dart:math';

import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final Random randomSeed = new Random();
  final TextEditingController textController;

  MainPage({this.textController});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 5),
      // Box with name
      SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed: () {},
          child: Text(Provider.of<PlayerManager>(context, listen: false).name),
        ),
      ),
      SizedBox(height: 5),
      // Button start game
      SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed: () => Provider.of<PlayerManager>(context, listen: false)
              .startGame(randomSeed.nextInt(0x7fffffff)),
          child: const Text("Start game with group"),
        ),
      ),
      SizedBox(height: 5),
      // Connected (indirect only) devices
      Expanded(
        child: Consumer<PlayerManager>(
          builder: (context, player, child) {
            var peers = player.getPeeredDevices();
            return ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: peers.length,
              itemBuilder: (BuildContext context, int index) {
                var device = peers.elementAt(index);
                return device.isDirect
                    ? Container()
                    : Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Center(child: Text(device.name)),
                              subtitle: Center(
                                  child: device.isAdhoc
                                      ? Text('(Indirect) AdHoc Player')
                                      : Text('(Indirect) Internet Player')),
                            ),
                            TextButton(
                              child: const Text('Indirectly Connected'),
                              onPressed: () => {},
                            ),
                          ],
                        ),
                      );
              },
            );
          },
        ),
      ),
    ]);
  }
}
