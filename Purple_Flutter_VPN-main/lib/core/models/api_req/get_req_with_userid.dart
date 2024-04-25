import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class ReqWithUserId extends BaseModel {
  static String userId = Preferences.getProfileId();

  ReqWithUserId({
    required super.methodName,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['user_id'] = userId;
    return baseJson;
  }
}
