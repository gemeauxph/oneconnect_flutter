import 'package:ndvpn/core/models/model.dart';

class UserRedeem extends Model {
  UserRedeem({
    required this.redeemId,
    required this.userPoints,
    required this.redeemPrice,
    required this.requestDate,
    required this.status,
  });

  final String redeemId;
  final String userPoints;
  final String redeemPrice;
  final String requestDate;
  final String status;

  factory UserRedeem.fromJson(Map<String, dynamic> json) => UserRedeem(
        redeemId: json["redeem_id"].toString(),
        userPoints: json["user_points"],
        redeemPrice: json["redeem_price"],
        requestDate: json["request_date"],
        status: json["status"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "redeem_id": redeemId,
        "user_points": userPoints,
        "redeem_price": redeemPrice,
        "request_date": requestDate,
        "status": status,
      };
}
