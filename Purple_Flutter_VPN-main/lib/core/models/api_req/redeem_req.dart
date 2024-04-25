import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class RedeemReq extends BaseModel {
  static String userId = Preferences.getProfileId();
  final String code;

  RedeemReq({required super.methodName, required this.code});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['user_id'] = userId;
    baseJson['code'] = code;
    return baseJson;
  }
}
