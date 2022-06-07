import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransitionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('The game has been started'),
      content: const Text('Would you like to join ?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Provider.of<PlayerManager>(context, listen: false).leaveGroup();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Provider.of<PlayerManager>(context, listen: false).joinGame(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
