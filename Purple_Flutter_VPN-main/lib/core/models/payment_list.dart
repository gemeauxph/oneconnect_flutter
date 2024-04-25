import 'package:ndvpn/core/models/model.dart';

class PaymentList extends Model {
  PaymentList({
    required this.id,
    required this.modeTitle,
  });

  final String id;
  final String modeTitle;

  factory PaymentList.fromJson(Map<String, dynamic> json) => PaymentList(
        id: json["id"],
        modeTitle: json["mode_title"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "mode_title": modeTitle,
      };
}
