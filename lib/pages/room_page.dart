import 'package:adhoc_gaming/adhoc/adhoc_player.dart';
import 'package:adhoc_gaming/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomPage extends StatelessWidget {
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
          // TODO
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
    //Provider.of<AdhocPlayer>(context, listen: false).leaveRoom();
    return Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => MainPage(),
    ));
  }
}
