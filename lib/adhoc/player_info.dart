import 'dart:convert';

class PlayerInfo {
  String name;
  bool master;

  PlayerInfo({this.name, this.master});

  PlayerInfo.fromJson(String jsonContent) {
    var json = jsonDecode(jsonContent);
    name = json['name'];
    master = json['master'];
  }

  Map toJson() => {
    'name': name,
    'master': master,
  };
}
