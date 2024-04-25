import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/utils/preferences.dart';

class SaveSpinnerPointsReq extends BaseModel {
  static String userId = Preferences.getProfileId();
  final String points;

  SaveSpinnerPointsReq({
    required super.methodName,
    required this.points,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['user_id'] = userId;
    baseJson['ponints'] = points;
    return baseJson;
  }
}
