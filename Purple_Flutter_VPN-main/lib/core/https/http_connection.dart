import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/model.dart';
import '../resources/environment.dart';

abstract class HttpConnection {
  final BuildContext context;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: endpoint,
    sendTimeout: const Duration(seconds: 20),
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    maxRedirects: 5,
  ));

  HttpConnection(this.context);

  Future get<T>(String url,
      {Map<String, String>? params,
      dynamic headers,
      bool pure = false,
      bool printDebug = false}) async {
    try {
      _printRequest("GET", url, body: params, showDebug: printDebug);
      var resp = await _dio.get(url + paramsToString(params),
          options: Options(headers: headers));
      _printResponse(resp, printDebug);
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse<T>.fromJson(resp.data);
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<VpnServer>> fetchData({required String key}) async {
    final response = await http.get(Uri.parse('$trueendpoint$key'));

    try {
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => VpnServer.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /*
  Future<List<VpnServer>> fetchOneConnectData(bool isFree, String key) async {

    String packageName = (await PackageInfo.fromPlatform()).packageName;

    final url = Uri.parse('https://developer.oneconnect.top/view/front/controller.php');
    final Map<String, String> formFields = {
      'package_name': packageName,
      'api_key': key,
      'action': 'fetchUserServers',
      'type': (isFree) ? 'free' : 'pro',
    };

    try {
      final response = await http.post(
        url,
        body: formFields, // Send the parameters as form fields
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => VpnServer.fromJson(data)).toList();
      } else {
        print('CHECKTEST Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('CHECKTEST Exception: $e');
      return [];
    }
  }

   */

  Future post<T>(String url,
      {Map<String, String>? params,
      dynamic body,
      dynamic headers,
      bool pure = false,
      bool printDebug = false}) async {
    try {
      _printRequest("POST", url, body: params, showDebug: printDebug);
      var resp = await _dio.post(url + paramsToString(params),
          data: body, options: Options(headers: headers));
      _printResponse(resp, printDebug);
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse<T>.fromJson(resp.data);
      }
    } catch (e) {
      return null;
    }
  }

  Future put<T>(String url,
      {Map<String, String>? params,
      dynamic body,
      dynamic headers,
      bool pure = false,
      bool printDebug = false}) async {
    try {
      _printRequest("PUT", url, body: params, showDebug: printDebug);
      var resp = await _dio.put(url + paramsToString(params),
          data: body, options: Options(headers: headers));
      _printResponse(resp, printDebug);
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse<T>.fromJson(resp.data);
      }
    } catch (e) {
      return null;
    }
  }

  Future delete<T>(String url,
      {Map<String, String>? params,
      dynamic body,
      dynamic headers,
      bool pure = false,
      bool printDebug = false}) async {
    try {
      _printRequest("DELETE", url, body: params, showDebug: printDebug);
      var resp = await _dio.delete(url + paramsToString(params),
          data: body, options: Options(headers: headers));
      _printResponse(resp, printDebug);
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse<T>.fromJson(resp.data);
      }
    } catch (e) {
      return null;
    }
  }

  static String paramsToString(Map<String, String>? params) {
    if (params == null) return "";
    String output = "?";
    params.forEach((key, value) {
      output += "$key=$value&";
    });
    return output.substring(0, output.length - 1);
  }

  void _printRequest(String type, String url,
      {Map<String, dynamic>? body, bool showDebug = false}) {
    if (kDebugMode && showDebug) {
      log("${type.toUpperCase()} REQUEST : $url \n");
      if (body != null) {
        try {
          JsonEncoder encoder = const JsonEncoder.withIndent('  ');
          String prettyprint = encoder.convert(body);
          log("BODY / PARAMETERS : $prettyprint");
        } catch (e) {
          log("CAN'T FETCH BODY");
        }
      }
    }
  }

  void _printResponse(dynamic response, [bool showDebug = false]) {
    String? prettyprint;
    if (response is Map) {
      try {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        prettyprint = encoder.convert(response);
      } catch (_) {}
    }
    if (kDebugMode && showDebug) {
      log(prettyprint ?? response.toString());
      log("=======================================================\n\n");
    }
  }

  Future<http.Response> postRequest(
      {required Map<String, dynamic> body}) async {
    try {
      final methodBody = jsonEncode(body);
      final response = await http.post(Uri.parse(AppConstants.baseURL),
          body: {'data': base64Encode(utf8.encode(methodBody))});
      return response;
    } catch (error) {
      throw 'Unexpected Error';
    }
  }
}

class ApiResponse<T> extends Model {
  ApiResponse({
    this.success = false,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  T? data;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };
}
