import 'package:ndvpn/core/models/model.dart';

class PurchaseHistory extends Model {
  String paymentMethod;
  String amount;
  String createDate;
  String type;

  PurchaseHistory(
      {required this.paymentMethod,
      required this.amount,
      required this.createDate,
      required this.type});

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      paymentMethod: json['payment_method'] ?? "",
      amount: json['amount'] ?? "",
      createDate: json['date_created'] ?? "",
      type: json['type'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "payment_method": paymentMethod,
        "amount": amount,
        "date_created": createDate,
        "type": type
      };
}
