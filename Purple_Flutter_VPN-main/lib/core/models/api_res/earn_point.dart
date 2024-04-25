import 'package:ndvpn/core/models/model.dart';

class EarnPoint extends Model {
  EarnPoint({
    required this.title,
    required this.points,
  });

  final String title;
  final String points;

  factory EarnPoint.fromJson(Map<String, dynamic> json) => EarnPoint(
        title: json["title"],
        points: json["points"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "title": title,
        "points": points,
      };
}
