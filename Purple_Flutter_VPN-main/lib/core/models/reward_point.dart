import 'package:ndvpn/core/models/model.dart';

class RewardPoint extends Model {
  RewardPoint({
    required this.id,
    required this.title,
    required this.statusThumbnail,
    required this.userId,
    required this.activityType,
    required this.points,
    required this.date,
    required this.time,
  });

  final String id;
  final String title;
  final String statusThumbnail;
  final String userId;
  final String activityType;
  final String points;
  final String date;
  final String time;

  factory RewardPoint.fromJson(Map<String, dynamic> json) => RewardPoint(
        id: json["id"].toString(),
        title: json["title"],
        statusThumbnail: json["status_thumbnail"],
        userId: json["user_id"],
        activityType: json["activity_type"],
        points: json["points"],
        date: json["date"],
        time: json["time"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "status_thumbnail": statusThumbnail,
        "user_id": userId,
        "activity_type": activityType,
        "points": points,
        "date": date,
        "time": time,
      };
}
