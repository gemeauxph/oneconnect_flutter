import 'package:ndvpn/core/models/api_req/base_model.dart';

class ContactUSMsgReq extends BaseModel {
  final String sendEmail;
  final String sendName;
  final String sendMessage;
  final String contactSubject;

  ContactUSMsgReq({
    required super.methodName,
    required this.sendEmail,
    required this.sendName,
    required this.sendMessage,
    required this.contactSubject,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> baseJson = super.toJson();
    baseJson['contact_email'] = sendEmail;
    baseJson['contact_name'] = sendName;
    baseJson['contact_msg'] = sendMessage;
    baseJson['contact_subject'] = contactSubject;
    return baseJson;
  }
}
