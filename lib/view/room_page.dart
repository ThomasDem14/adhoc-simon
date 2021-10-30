import 'package:adhoc_gaming/model/game_constants.dart';
import 'package:adhoc_gaming/model/game_room.dart';
import 'package:adhoc_gaming/model/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:provider/provider.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ad Hoc Game Room'),
      ),
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(flex: 1, child: Text('Number of players')),
                      Expanded(
                        flex: 1,
                        child: Consumer<GameRoom>(
                          builder: (context, config, child) => SpinBox(
                            min: 2,
                            max: 12,
                            value: config.getMaxPlayers(),
                            onChanged: (value) {
                              config.setMaxPlayers(value);
                              Provider.of<Player>(context, listen: false).advertiseRoom(config.getUuid(), config.configToJson());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(flex: 1, child: Text('Game type')),
                      Expanded(
                        flex: 1,
                        child: Consumer<GameRoom>(
                          builder: (context, config, child) => ToggleButtons(
                            children: [
                              Text('Coop'),
                              Text('Survie'),
                            ],
                            onPressed: (index) {
                              config.setGameType(index == 0
                                  ? GameType.coop
                                  : GameType.survival);
                              Provider.of<Player>(context, listen: false).advertiseRoom(config.getUuid(), config.configToJson());
                            },
                            isSelected: [
                              config.getGameType() == GameType.coop,
                              config.getGameType() == GameType.survival
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) => Container(
                child: Row(children: [
                  Text(Provider.of<Player>(context, listen: false).getName()),
                  Container(
                    child:
                        Provider.of<Player>(context, listen: false).getMaster()
                            ? Icon(Icons.star)
                            : null,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
