import 'package:ndvpn/core/models/api_req/base_model.dart';

class UserLoginReq extends BaseModel {
  static const String playerId = '123';
  final String email;
  final String password;

  UserLoginReq({
    required super.methodName,
    required this.email,
    required this.password,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['email'] = email;
    baseJson['password'] = password;
    baseJson['player_id'] = playerId;
    return baseJson;
  }
}
