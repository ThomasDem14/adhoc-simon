import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
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
            Provider.of<AdhocPlayer>(context, listen: false).leaveGroup();
            Navigator.pop(context, 'Leave');
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'Join'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
