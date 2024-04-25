import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class UserProfileUpdate extends BaseModel {
  static String userId = Preferences.getProfileId();
  final String name;
  final String email;
  final String password;
  final String phone;
  final String userYoutube;
  final String userInstagram;

  UserProfileUpdate(
      {required super.methodName,
      required this.name,
      required this.email,
      required this.password,
      required this.phone,
      required this.userYoutube,
      required this.userInstagram});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['user_id'] = userId;
    baseJson['name'] = name;
    baseJson['email'] = email;
    baseJson['password'] = password;
    baseJson['phone'] = phone;
    baseJson['user_youtube'] = userYoutube;
    baseJson['user_instagram'] = userInstagram;
    return baseJson;
  }
}
