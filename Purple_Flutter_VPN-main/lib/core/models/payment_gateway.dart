import 'package:ndvpn/core/models/model.dart';

class PaymentGateway extends Model {
  PaymentGateway({
    required this.id,
    required this.name,
    required this.status,
    required this.privateKey,
    required this.publicKey,
    required this.otherKey,
    required this.currency,
  });

  final String id;
  final String name;
  final String status;
  final String privateKey;
  final String publicKey;
  final String otherKey;
  final String currency;

  factory PaymentGateway.fromJson(Map<String, dynamic> json) =>
      PaymentGateway(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        privateKey: json["private_key"],
        publicKey: json["public_key"],
        otherKey: json["other_key"],
        currency: json["currency"],
      );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "status": status,
    "private_key": privateKey,
    "public_key": publicKey,
    "other_key": otherKey,
    "currency": currency,
  };
}
