class UserRegisterModel {
  String methodName;
  String type;
  String deviceId;
  String name;
  String email;
  String password;
  String phone;
  String playerId;
  String userReferenceCode;

  UserRegisterModel({
    required this.methodName,
    required this.type,
    required this.deviceId,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.playerId,
    required this.userReferenceCode,
  });

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterModel(
      methodName: json['method_name'],
      type: json['type'],
      deviceId: json['device_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      playerId: json['player_id'],
      userReferenceCode: json['user_reference_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method_name': methodName,
      'type': type,
      'device_id': deviceId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'player_id': playerId,
      'user_reference_code': userReferenceCode,
    };
  }
}
