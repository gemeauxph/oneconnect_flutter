import 'package:ndvpn/core/models/model.dart';

class SubscriptionPlan extends Model {
  SubscriptionPlan({
    required this.name,
    required this.productId,
    required this.stripeProductId,
    required this.revenueCatId,
    required this.price,
    required this.currency,
    required this.status,
  });

  final String name;
  final String productId;
  final String stripeProductId;
  final String revenueCatId;
  final String price;
  final String currency;
  final String status;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        name: json["name"],
        productId: json["product_id"],
        stripeProductId: json["stripe_product_id"],
        revenueCatId: json["revenuecat_id"],
        price: json["price"],
        currency: json["currency"],
        status: json["status"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        "product_id": productId,
        "stripe_product_id": stripeProductId,
        "revenuecat_id": revenueCatId,
        "price": price,
        "currency": currency,
        "status": status,
      };
}
