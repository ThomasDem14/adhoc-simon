import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/game/game_widgets.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamePage extends StatelessWidget {
  final gameWidgets = new GameWidgets();

  @override
  Widget build(BuildContext context) {
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
          // Players and leds
          Expanded(
            flex: 4,
            child: Consumer<AdhocPlayer>(
              builder: (context, player, child) {
                var players = player.getPlayers();
                return ListView.separated(
                  padding: EdgeInsets.all(15.0),
                  itemCount: players.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(players.elementAt(index).name),
                        gameWidgets.ledButton(GameColors.Default),
                        gameWidgets.ledButton(GameColors.Default),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                );
              },
            ),
          ),
          // Buttons
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Level indicator
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Level"),
                        Text(Provider.of<SimonGame>(context)
                            .getLevel()
                            .toString()),
                      ],
                    ),
                  ),
                ),
                // Color buttons
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(children: [
                      Row(children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(GameColors.Red),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(GameColors.Yellow),
                        ),
                      ]),
                      Row(children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(GameColors.Blue),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(GameColors.Green),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
      onWillPop: () => onReturn(context),
    );
  }

  Future<void> onReturn(BuildContext context) async {
    Provider.of<AdhocPlayer>(context, listen: false).leaveGroup();
    return Navigator.of(context).pushReplacementNamed('/');
  }
}
