import 'package:adhoc_gaming/model/game_constants.dart';
import 'package:adhoc_gaming/model/game_room.dart';
import 'package:adhoc_gaming/model/player.dart';
import 'package:adhoc_gaming/view/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:provider/provider.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Add the current player in the list of players
    Player player = Provider.of<Player>(context, listen: false);
    GameRoom gameRoom = Provider.of<GameRoom>(context, listen: false);
    gameRoom.addPlayer(player.getPlayerInfo());
    player.advertiseRoom(gameRoom.getUuid(), gameRoom.configToJson());
    // Will only be called during the first build 

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Ad Hoc Game Room'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => onReturn(context),
          ),
        ),
        body: Column(children: [
          // Settings
          Expanded(
            flex: 4,
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
                              value: config.getMaxPlayers().toDouble(),
                              onChanged: (value) {
                                config.setMaxPlayers(value.toInt());
                                Provider.of<Player>(context, listen: false)
                                    .advertiseRoom(config.getUuid(),
                                        config.configToJson());
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
                                Provider.of<Player>(context, listen: false)
                                    .advertiseRoom(config.getUuid(),
                                        config.configToJson());
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
          // Players
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Consumer<GameRoom>(
                  builder: (context, room, child) => Text(
                      'Players (${room.getNumberPlayers()}/${room.getMaxPlayers()}):',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Consumer<GameRoom>(
                    builder: (context, room, child) => ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: room.getNumberPlayers(),
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                        child: Row(children: [
                          Text(room.getPlayerInfo(index).name),
                          Container(
                            child: room.getPlayerInfo(index).master
                                ? Icon(Icons.star)
                                : null,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Buttons
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => onReturn(context),
                    child: const Text("Exit"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Start game"),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
      onWillPop: () => onReturn(context),
    );
  }

  Future<void> onReturn(BuildContext context) {
    Provider.of<Player>(context, listen: false).leaveRoom();
    return Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MainPage(),
    ));
  }
}
