
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/constant.dart';

part 'forget_password_event.dart';
part 'forget_password_state.dart';

class ForgetPasswordBloc extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(ForgetPasswordInitial()) {
    on<ForgetPasswordEvent>((event, emit) {});
    on<ForgetPasswordCall>((event, emit) async{
      String email=event.email;
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'forgot_pass',
      'email': email
    });
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          ForgetPasswordFail(message: message);
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg=data['msg'];
          ForgetPasswordSuccess(message: msg);
        }
      } else {
        const ForgetPasswordFail(message: 'Failed. Try again.');
      }
    } catch (e) {
      const ForgetPasswordFail(message: 'Server timeout');
    }
    },);
  }
}
