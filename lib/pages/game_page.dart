import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/game/game_widgets.dart';
import 'package:adhoc_gaming/game/simon_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamePage extends StatelessWidget {
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

                      bool result = game.processInput(color);
                      if (!result) {
                        game.setGameOver();
                      }

                      Provider.of<AdhocPlayer>(context, listen: false)
                          .sendColorTapped(color);
                    },
                    colorToDisplay: () => game.getCurrentColor(),
                    child: game.isPlayingSequence()
                        ? const Text("Sequence playing")
                        : Text(game.getPlayerTurn() == 0
                            ? "You"
                            : Provider.of<AdhocPlayer>(context, listen: false)
                                .getPlayerName(Provider.of<AdhocPlayer>(context,
                                        listen: false)
                                    .getPeeredDevices()
                                    .elementAt(game.getPlayerTurn())
                                    .label)),
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
