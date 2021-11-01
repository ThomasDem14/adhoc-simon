import 'package:uuid/uuid.dart';

class PlayerInfo {
  String name;
  String uuid;
  bool master;

  PlayerInfo({this.name, this.master}) {
    uuid = Uuid().v4();
  }
}
