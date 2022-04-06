import 'dart:async';

import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/game/game_widgets.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<StreamSubscription> _subscriptions = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    _subscriptions.add(Provider.of<PlayerManager>(context, listen: false)
        .colorStream
        .listen((GameColors color) {
      Provider.of<SimonGame>(context, listen: false).processInput(color);
    }));

    _subscriptions.add(Provider.of<PlayerManager>(context, listen: false)
        .levelGameStream
        .listen((int restart) {
      if (restart == ServiceManager.RESTART_GAME) {
        Provider.of<SimonGame>(context, listen: false).restart();
      } else if (restart == ServiceManager.NEXT_LEVEL) {
        Provider.of<SimonGame>(context, listen: false).startLevel();
      } else {
        Provider.of<SimonGame>(context, listen: false).reset(restart);
      }
    }));
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) {
      sub.cancel();
    });
    Provider.of<PlayerManager>(context, listen: false).dispose();
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

                      Provider.of<PlayerManager>(context, listen: false)
                          .sendColorTapped(color);
                    },
                    colorToDisplay: game.getCurrentColor(),
                    child: game.isPlayingSequence()
                        ? const Text("Sequence playing")
                        : Text(
                            Provider.of<PlayerManager>(context, listen: false)
                                .getPeeredDevices()
                                .elementAt(game.getPlayerTurn())
                                .name),
                  );
                },
              ),
            ),
            Container(
              child: Provider.of<SimonGame>(context).isGameOver()
                  ? ElevatedButton(
                      child: const Text("Restart"),
                      onPressed: () =>
                          Provider.of<PlayerManager>(context, listen: false)
                              .sendNextLevel(ServiceManager.RESTART_GAME),
                    )
                  : ElevatedButton(
                      child: const Text("Continue"),
                      onPressed: () =>
                          Provider.of<PlayerManager>(context, listen: false)
                              .sendNextLevel(ServiceManager.NEXT_LEVEL),
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
    Provider.of<PlayerManager>(context, listen: false).leaveGroup();
    dispose();
    Navigator.of(context).pop();
    return Navigator.of(context).pop();
  }
}
