class ConnectedDevice {
  String id;
  bool isAdhoc;
  String name;

  ConnectedDevice(String id, bool isAdhoc, String name) {
    this.id = id;
    this.isAdhoc = isAdhoc;
    this.name = name;
  }

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      json['id'],
      json['isAdhoc'],
      json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isAdhoc': isAdhoc,
        'name': name,
      };
}
