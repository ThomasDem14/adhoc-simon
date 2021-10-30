import 'package:adhoc_gaming/model/game_room.dart';
import 'package:adhoc_gaming/model/player.dart';
import 'package:adhoc_gaming/view/room_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ad Hoc Main Room'),
      ),
      body: Column(children: [
        Expanded(
          flex: 2,
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
                  'Player',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Consumer<Player>(
                      builder: (context, player, child) => TextField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your name'),
                            controller: textController,
                            onChanged: (text) => player.setName(text),
                          )),
                ),
                Expanded(
                  child: Container(),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: (){ 
                Provider.of<Player>(context, listen: false).setMaster(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => GameRoom(),
                      child: RoomPage(),
                    ),
                  ));
              },
              child: const Text("Create Room"),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => {},
              child: const Text("Join Room"),
            ),
          ),
        ),
      ]),
    );
  }
}