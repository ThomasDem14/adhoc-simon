class ConnectedDevice {
  /// UUID defined by the application.
  String uuid;

  /// Unique ID defined by the plugin.
  String id;

  /// Human readable name (not always unique).
  String name;

  /// True if from an adhoc network, false if from Internet.
  bool isAdhoc;

  /// True if it is a direct peer, false if known from a peer.
  bool isDirect;

  ConnectedDevice({this.uuid, this.id, this.name, this.isAdhoc, this.isDirect});

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      uuid: json['uuid'],
      id: json['id'],
      name: json['name'],
      isAdhoc: json['isAdhoc'],
      isDirect: json['isDirect'],
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'id': id,
        'name': name,
        'isAdhoc': isAdhoc,
        'isDirect': isDirect,
      };
}
