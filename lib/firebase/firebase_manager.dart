import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:adhoc_gaming/player/connected_device.dart';
import 'package:adhoc_gaming/player/message_type.dart';
import 'package:adhoc_gaming/game/game_constants.dart';
import 'package:adhoc_gaming/player/service_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseManager extends ServiceManager {
  FirebaseDatabase _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://adhoc-simon-default-rtdb.europe-west1.firebasedatabase.app/");

  late DatabaseReference _reference;

  String? _roomId;
  StreamSubscription? _subscription;

  late StreamSubscription _connectivitySubscription;

  FirebaseManager(String uuid) : super(uuid);

  ///******** ServiceManager functions ********/

  void enable(String name) {
    this.name = name;

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Check for Internet connectivity.
      if (result == ConnectivityResult.wifi) {
        // If it was disabled, enable.
        if (!this.enabled) {
          print('[FirebaseManager] Enabled');
          this.enabled = true;
          connectivityController.add(true);
          _roomId = _randomRoom();
          _listen(_roomId);
        }
      } else if (result == ConnectivityResult.none) {
        // If it was enabled, disable.
        if (this.enabled) {
          print('[FirebaseManager] Disabled');
          this.enabled = false;
          connectivityController.add(false);
        }
      }
    });
  }

  void dispose() async {
    await _leaveProcess();
    _subscription?.cancel();
    _connectivitySubscription.cancel();
  }

  void transferMessage(Map data) {
    if (!this.enabled) return;

    // Remove the peers entry because it is a Firebase message.
    data.remove("peers");
    // Override with your id.
    // NB: With FireBase devices, id == uuid.
    data['uuid'] = this.uuid;
    data['id'] = this.uuid;
    _reference.push().set(data);
  }

  void notifyNewConnection(List<ConnectedDevice> devices) {
    if (!this.enabled) return;

    _reference.push().set({
      "type": MessageType.indirectConnection.name,
      "uuid": uuid,
      "id": uuid,
      "connections": jsonEncode(devices),
    });
  }

  void notifyDisconnected(ConnectedDevice device) {
    if (!this.enabled) return;

    _reference.push().set({
      "type": MessageType.indirectConnection.name,
      "uuid": uuid,
      "id": uuid,
      "disconnected": jsonEncode(device),
    });
  }

  void leaveGroup() async {
    if (!this.enabled) return;

    await _leaveProcess();

    // Create a new room.
    _roomId = _randomRoom();
    _listen(_roomId);
  }

  void sendColorTapped(GameColors color) async {
    if (!this.enabled) return;

    _reference.push().set({
      "type": MessageType.sendColorTapped.name,
      "id": uuid,
      "uuid": uuid,
      "color": color.name,
    });
  }

  void sendNextLevel(int restart) async {
    if (!this.enabled) return;

    _reference.push().set({
      "type": MessageType.sendLevelChange.name,
      "id": uuid,
      "uuid": uuid,
      "restart": restart,
    });
  }

  void startGame(int seed) async {
    if (!this.enabled) return;

    _reference.push().set({
      "type": MessageType.startGame.name,
      "id": uuid,
      "uuid": uuid,
      "seed": seed,
    });
  }

  ///******** Specific to FirebaseManager ********/

  // Connect to a new room and start listening to the messages in that room.
  void connectRoom(String roomId) async {
    if (!this.enabled) return;

    // Leave the current room.
    await _leaveProcess();

    // TODO: Check if room exists (optional)
    _roomId = roomId;
    await _listen(roomId);

    _reference.push().set({
      "type": MessageType.firebaseConnection.name,
      "name": name,
      "id": uuid,
      "uuid": uuid,
    });
  }

  // Listen to messages sent in the room specified by $id.
  Future _listen(String? roomId) async {
    _subscription?.cancel();

    // Fetch users already in the room.
    DataSnapshot snapshot = await _database.ref('rooms/$roomId/users').get();
    if (snapshot.exists) {
      // For each user, send a firebaseConnection message.
      var object = snapshot.value as Map;
      for (Object objectUuid in object.keys) {
        streamController.add({
          "type": MessageType.firebaseConnection.name,
          "name": object[objectUuid]["name"].toString(),
          "id": objectUuid.toString(),
          "uuid": objectUuid.toString(),
        });
      }
    }

    // Add yourself in the user list.
    _database.ref('rooms/$_roomId/users/$uuid').set({
      "name": name,
    });

    // Listen to the message channel.
    _reference = _database.ref('rooms/$roomId/messages');
    _subscription = _reference.onChildAdded.listen((DatabaseEvent event) {
      var data = event.snapshot.value as Map;

      // Do not consider messages from yourself from Firebase.
      var senderId = data['uuid'] as String;
      if (uuid == senderId) return;

      streamController.add(data);
    });
  }

  // Implements the operations required when leaving a group.
  Future _leaveProcess() async {
    // Send leaveGroup message.
    await _reference.push().set({
      "type": MessageType.leaveGroup.name,
      "id": uuid,
      "uuid": uuid,
    });

    // Remove yourself from the user list.
    _database.ref('rooms/$_roomId/users/$uuid').remove();

    // If no more users, delete channel.
    DataSnapshot snapshot = await _database.ref('rooms/$_roomId/users').get();
    if (!snapshot.exists) {
      _reference.remove();
    }
  }

  // Generate a new random 6-digit code.
  String _randomRoom() {
    var rng = new Random();
    var code = rng.nextInt(900000) + 100000;
    return code.toString();
  }

  String? getRoomId() => _roomId;
}
