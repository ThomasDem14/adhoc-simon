class ConnectedDevice {
  String id;
  String name;
  bool isAdhoc;
  bool isDirect;

  ConnectedDevice(String id, String name, bool isAdhoc, bool isDirect) {
    this.id = id;
    this.name = name;
    this.isAdhoc = isAdhoc;
    this.isDirect = isDirect;
  }

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      json['id'],
      json['name'],
      json['isAdhoc'],
      json['isDirect'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isAdhoc': isAdhoc,
        'isDirect': isDirect,
      };
}
