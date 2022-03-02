import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseManager extends ServiceManager {
  FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://adhoc-simon-default-rtdb.europe-west1.firebasedatabase.app/");
  DatabaseReference _reference;

  String _roomId;
  StreamSubscription _subscription;

  FirebaseManager(id) : super(id) {
    _roomId = _randomRoom();
    _listen(_roomId);
  }

  ///******** ServiceManager functions ********/

  void setName(String name) async {
    this.name = name;

    await _reference.push().set({
      "type": MessageType.changeName.name,
      "name": name,
      "id": id,
    });
  }

  void leaveGroup() async {
    await _reference.push().set({
      "type": MessageType.leaveGroup.name,
      "id": id,
    });

    // Create a new room.
    _listen(_randomRoom());
  }

  void sendColorTapped(GameColors color) async {
    await _reference.push().set({
      "type": MessageType.sendColorTapped.name,
      "id": id,
      "color": color,
    });
  }

  void sendNextLevel(bool restart) async {
    await _reference.push().set({
      "type": MessageType.sendLevelChange.name,
      "id": id,
      "restart": restart,
    });
  }

  void startGame(int seed, List<ConnectedDevice> players) async {
    await _reference.push().set({
      "type": MessageType.startGame.name,
      "id": id,
      "seed": seed,
      "players": jsonEncode(players),
    });
  }

  ///******** Specific to FirebaseManager ********/

  // Connect to a new room and start listening to the messages in that room.
  void connectRoom(String roomId) async {
    _roomId = roomId;
    _listen(roomId);

    await _reference.push().set({
      "type": MessageType.firebaseConnection.name,
      "id": id,
    });
  }

  // Listen to messages sent in the room specified by $id.
  void _listen(String roomId) {
    if (_subscription != null) _subscription.cancel();

    _reference = _database.ref('rooms/$roomId');

    _subscription = _reference.onChildAdded.listen((DatabaseEvent event) {
      var data = event.snapshot.value as Map;
      streamController.add(data);
    });
  }

  // Generate a new random 6-digit code.
  String _randomRoom() {
    var rng = new Random();
    var code = rng.nextInt(900000) + 100000;
    return code.toString();
  }

  String getRoomId() => _roomId;
}
