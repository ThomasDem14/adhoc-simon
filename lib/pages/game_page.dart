import 'dart:async';

import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/game/game_widgets.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Provider.of<AdhocPlayer>(context, listen: false)
        .colorStream
        .listen((color) {
      Provider.of<SimonGame>(context, listen: false).processInput(color);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              "Level " + Provider.of<SimonGame>(context).getLevel().toString()),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => onReturn(context),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Consumer<SimonGame>(
                builder: (context, game, child) {
                  return GameWidgets(
                    onTap: (GameColors color) {
                      if (!game.isWaitingForInput()) return;

                      Provider.of<AdhocPlayer>(context, listen: false)
                          .sendColorTapped(color);
                    },
                    colorToDisplay: () => game.getCurrentColor(),
                    child: game.isPlayingSequence()
                        ? const Text("Sequence playing")
                        : Text(Provider.of<AdhocPlayer>(context, listen: false)
                            .getPlayers()
                            .elementAt(game.getPlayerTurn())),
                  );
                },
              ),
            ),
            Container(
              child: Provider.of<SimonGame>(context).isGameOver()
                  ? ElevatedButton(
                      child: const Text("Restart"),
                      onPressed: Provider.of<SimonGame>(context, listen: false)
                          .restart,
                    )
                  : ElevatedButton(
                      child: const Text("Continue"),
                      onPressed: Provider.of<SimonGame>(context, listen: false)
                          .startLevel,
                    ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      onWillPop: () => onReturn(context),
    );
  }

  Future<void> onReturn(BuildContext context) async {
    Provider.of<AdhocPlayer>(context, listen: false).leaveGroup();
    return Navigator.of(context).pop();
  }
}
