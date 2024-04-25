import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/preferences.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterEvent>((event, emit) {});

    on<VerificationCall>(
      (event, emit) async {
        emit(RegisterInitial());
        String email = event.email;
        String otp = event.otp;
        String methodBody = jsonEncode({
          'sign': AppConstants.sign,
          'salt': AppConstants.randomSalt.toString(),
          'package_name': AppConstants.packageName,
          'method_name': 'user_register_verify_email',
          'email': email,
          'otp_code': otp
        });
        try {
          http.Response response = await http.post(
            Uri.parse(AppConstants.baseURL),
            body: {'data': base64Encode(utf8.encode(methodBody))},
          );
          if (response.statusCode == 200) {
            Map<String, dynamic> jsonResponse = jsonDecode(response.body);
            if (jsonResponse.containsKey(AppConstants.status)) {
              String message = jsonResponse['message'];
              emit(RegisterFail(message: message));
            } else {
              Map<String, dynamic> data = jsonResponse[AppConstants.tag];
              String msg = data['msg'];
              String success = "${data['success']}";
              if (success == '1') {
                Fluttertoast.showToast(
                    msg: msg, toastLength: Toast.LENGTH_SHORT);
                Preferences.setOtp(verificationCode: otp);
                emit(VerificationSuccess());
              } else {
                emit(RegisterFail(message: msg));
              }
            }
          }
        } on Exception catch (_) {
          emit(const RegisterFail(message: 'Failed Try Again'));
        }
      },
    );

    on<RegistationCall>((event, emit) async {
      emit(RegisterInitial());
      String deviceId = event.deviceid;
      String name = event.name;
      String email = event.email;
      String password = event.passwrod;
      String phone = event.phoneNo;
      String reference = event.reference;
      String methodBody = jsonEncode({
        'sign': AppConstants.sign,
        'salt': AppConstants.randomSalt.toString(),
        'package_name': AppConstants.packageName,
        'method_name': 'user_register',
        'type': 'normal',
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'device_id': deviceId,
        'user_refrence_code': reference
      });
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('status')) {
          String message = jsonResponse['message'];
          emit(RegistationFail(message: message));
        } else {
          Map<String, dynamic> data = jsonResponse[AppConstants.tag];
          String msg = data['msg'];
          String success = "${data['success']}";
          Preferences.setVerification(isVerification: false);
          if (success == '1') {
            emit(const RegisterSuccess());
          }
          Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
        }
      }
    });
  }
}
