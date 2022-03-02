import 'package:adhoc_gaming/player/player_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InternetPage extends StatelessWidget {
  final TextEditingController textController;

  InternetPage({this.textController});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 5),
      // Your room id
      SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            textStyle: TextStyle(color: Colors.white),
            primary: Colors.blue,
          ),
          onPressed: () => {},
          child:
              Text("Room " + Provider.of<PlayerManager>(context).getRoomId()),
        ),
      ),
      SizedBox(height: 5),
      // Button to join another room by id
      SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the 6-digit code',
                ),
                controller: textController,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 0),
                    textStyle: TextStyle(color: Colors.white),
                    primary: Colors.blue,
                  ),
                  onPressed: () =>
                      Provider.of<PlayerManager>(context, listen: false)
                          .connectRoom(textController.text),
                  child: const Text("Join"),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 5),
      // Connected (internet only) devices
      Expanded(
        child: Consumer<PlayerManager>(
          builder: (context, player, child) {
            var peers = player.getPeeredDevices();
            return ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemCount: peers.length,
              itemBuilder: (BuildContext context, int index) {
                var device = peers.elementAt(index);
                return device.isAdhoc
                    ? Container()
                    : Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Center(child: Text(device.name)),
                              subtitle: Center(child: Text('Internet player')),
                            ),
                            TextButton(
                              child: const Text('Connected'),
                              onPressed: () => {},
                            ),
                          ],
                        ),
                      );
              },
            );
          },
        ),
      ),
    ]);
  }
}
