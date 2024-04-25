import 'package:ndvpn/core/models/model.dart';

class AboutData extends Model {
  final String appFaq;
  final String appName;
  final String appLogo;
  final String appVersion;
  final String appAuthor;
  final String appContact;
  final String appEmail;
  final String appWebsite;

  AboutData({
    required this.appFaq,
    required this.appName,
    required this.appLogo,
    required this.appVersion,
    required this.appAuthor,
    required this.appContact,
    required this.appEmail,
    required this.appWebsite,
  });

  factory AboutData.fromJson(Map<String, dynamic> json) {
    return AboutData(
        appFaq: json["app_description"],
        appName: json["app_name"],
        appLogo: json["app_logo"],
        appVersion: json["app_version"],
        appAuthor: json["app_author"],
        appContact: json["app_contact"],
        appEmail: json["app_email"],
        appWebsite: json["app_website"]);
  }

  @override
  Map<String, dynamic> toJson() => {
        "app_description": appFaq,
        "app_name": appName,
        "app_logo": appLogo,
        "app_version": appVersion,
        "app_author": appAuthor,
        "app_contact": appContact,
        "app_email": appEmail,
        "app_website": appWebsite,
      };
}
