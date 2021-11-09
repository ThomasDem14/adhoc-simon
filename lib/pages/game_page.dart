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
            child: ListView.builder(
              padding: EdgeInsets.all(15.0),
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Player $index"),
                    gameWidgets.ledButton(Colors.white),
                    gameWidgets.ledButton(Colors.white),
                  ],
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
                          child: gameWidgets.ledButton(RED_COLOR),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(YELLOW_COLOR),
                        ),
                      ]),
                      Row(children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(BLUE_COLOR),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: gameWidgets.ledButton(GREEN_COLOR),
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

  Future<void> onReturn(BuildContext context) {
    Provider.of<AdhocPlayer>(context, listen: false).leaveGroup();
    return Navigator.of(context).pushReplacementNamed('/');
  }
}
