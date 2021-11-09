import 'dart:convert';

import 'package:uuid/uuid.dart';

class PlayerInfo {
  String name;
  bool master;
  String uuid;

  PlayerInfo({this.name, this.master}) {
    uuid = Uuid().v4();
  }

  PlayerInfo.fromJson(String jsonContent) {
    var json = jsonDecode(jsonContent);
    name = json['name'];
    master = json['master'];
    uuid = json['uuid'];
  }

  Map toJson() => {
        'name': name,
        'master': master,
        'uuid': uuid,
      };
}
