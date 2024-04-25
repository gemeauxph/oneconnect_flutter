import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class PaymentReq extends BaseModel {
  static String userId = Preferences.getProfileId();
  final String userPoints;
  final String paymentMode;
  final String detail;

  PaymentReq({
    required super.methodName,
    required this.userPoints,
    required this.paymentMode,
    required this.detail,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['user_id'] = userId;
    baseJson['user_points'] = userPoints;
    baseJson['payment_mode'] = paymentMode;
    baseJson['bank_details'] = detail;
    return baseJson;
  }
}
