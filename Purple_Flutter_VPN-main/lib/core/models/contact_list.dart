import 'package:ndvpn/core/models/model.dart';

class ContactList extends Model {
  ContactList({
    required this.id,
    required this.subject,
  });

  final String id;
  final String subject;

  factory ContactList.fromJson(Map<String, dynamic> json) => ContactList(
        id: json["id"],
        subject: json["subject"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "subject": subject,
      };
}
