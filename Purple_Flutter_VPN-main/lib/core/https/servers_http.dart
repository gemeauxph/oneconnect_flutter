import 'dart:convert';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/https/http_connection.dart';
import 'package:ndvpn/core/models/api_req/base_model.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/api_req/redeem_req.dart';
import 'package:ndvpn/core/models/api_res/about_data.dart';
import 'package:ndvpn/core/models/api_res/app_settings.dart';
import 'package:ndvpn/core/models/api_res/earn_point.dart';
import 'package:ndvpn/core/models/ip_detail.dart';
import 'package:ndvpn/core/models/purchase_history.dart';
import 'package:ndvpn/core/models/vpn_config.dart';
import 'package:oneconnect_flutter/openvpn_flutter.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/redeem_dialog.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'dart:io';

class ServersHttp extends HttpConnection {
  ///All serveres request api
  ServersHttp(super.context);

  ///Get all servers from backend
  Future<List<VpnConfig>> allServers() async {
    ApiResponse<List> resp = await get<List>("allservers");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<VpnServer>> allTrueServers() async {


    List<VpnServer> vpnServerList = [];

    var oneConnectKey = "";

    if (Platform.isAndroid) {
      oneConnectKey = AppConstants.oneConnectKey;
    } else {
      oneConnectKey = AppConstants.oneConnectKey2;
    }

    print("CHECKKEY $oneConnectKey");

    if (AppConstants.isOneConnect) {
      vpnServerList.addAll(await OpenVPN().oneConnectServers(true, oneConnectKey)); //Free
      vpnServerList.addAll(await OpenVPN().oneConnectServers(false, oneConnectKey)); //Pro
    } else {
      vpnServerList.addAll(await fetchData(key: "frs"));
      vpnServerList.addAll(await fetchData(key: "prs"));
    }
    return vpnServerList;
  }

  ///Get all free servers from backend
  Future<List<VpnConfig>> allFree() async {
    ApiResponse<List> resp = await get<List>("allservers/free");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  ///Get all pro servers from backend
  Future<List<VpnConfig>> allPro() async {
    ApiResponse<List> resp = await get<List>("allservers/pro");
    if (resp.success ?? false) {
      return resp.data!.map<VpnConfig>((e) => VpnConfig.fromJson(e)).toList();
    }
    return [];
  }

  ///Randomly get server
  Future<VpnConfig?> random() async {
    ApiResponse<Map<String, dynamic>> resp =
        await get<Map<String, dynamic>>("detail/random");
    if (resp.success ?? false) {
      return VpnConfig.fromJson(resp.data!);
    }
    return null;
  }

  ///Fetch server's detail by slug
  Future<VpnConfig?> serverDetail(String slug) async {
    ApiResponse<Map<String, dynamic>> resp =
        await get<Map<String, dynamic>>("detail/$slug");
    if (resp.success ?? false) {
      return VpnConfig.fromJson(resp.data!);
    }
    return null;
  }

  ///Get IP informations
  Future<IpDetail?> getPublicIP() async {
    var resp = await get("https://myip.wtf/json", pure: true);
    return resp != null ? IpDetail.fromJson(resp) : null;
  }

  bool _handleStatus(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey("status")) {
      final status = jsonData["status"];
      final message = jsonData["message"];

      if (status == "-2") {
        replaceScreen(context, const LoginScreen());
        showToast(message);
      } else {
        showToast(message);
      }
      return false;
    }
    return true;
  }

  void _updateConfig(
      {required Map<String, dynamic> data, required bool ingorePremium}) {
    String noAds = data["no_ads"];
    String premiumServers = data["premium_servers"];
    String isPremium = data["is_premium"] ?? "";
    String perks = data["perks"];
    String exp = data["exp"];

    Config.noAds = noAds == "1";
    Config.premiumServersAccess = premiumServers == "1";
    if (!ingorePremium) {
      Config.isPremium = isPremium == "1";
    }
    Config.perks = perks;
    Config.expiration = exp;

    IAPProvider.read(context).updateProStatus();
  }

  Future<List<EarnPoint>> rewardPoint() async {
    BaseModel req = BaseModel(methodName: 'points_details');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        return data
            .map<EarnPoint>((object) =>
                EarnPoint(title: object['title'], points: object['point']))
            .toList();
      }
    }
    return [];
  }

  Future<List<PurchaseHistory>> fetchPurchaseHistory() async {
    ReqWithUserId req = ReqWithUserId(methodName: "fetch_purchase_history");
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        if (data.containsKey('list') && data['list'] != null) {
          dynamic listData = data['list'];
          if (listData != null) {
            if (listData is String) {
              List<dynamic> decodedList = json.decode(listData);
              if (decodedList.isNotEmpty) {
                return List<PurchaseHistory>.from(
                    decodedList.map((item) => PurchaseHistory.fromJson(item)));
              }
            }
          }
        }
      }
    }
    return [];
  }

  Future<String> referenceCode() async {
    //BaseModel req = BaseModel(methodName: 'user_profile');
    ReqWithUserId req = ReqWithUserId(methodName: "user_profile");

    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          return data["user_code"];
        }
      }
    }
    return '';
  }

  Future<void> redeem({required String code}) async {
    RedeemReq req = RedeemReq(methodName: 'redeem_code', code: code);
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    final response = await postRequest(body: req.toJson());
    customProgressDialog.dismiss();
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        String msg = data['msg'];
        if (success == "1") {
          _updateConfig(data: data, ingorePremium: true);
          showRedeemDialog(
              title: 'Success!',
              perks: data['perks'],
              exp: data['exp'],
              btn: 'Back To Home',
              isFinish: true,
              context: context);
        } else {
          showToast(msg);
        }
      }
    }
  }

  Future<AboutData?> getAboutData() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'app_about');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          return AboutData.fromJson(data);
        }
      }
    }
    return null;
  }

  Future<AppSettings?> getAppSettings() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'app_settings');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          return AppSettings.fromJson(data);
        }
      }
    }
    return null;
  }

  Future<String> getFaq() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'app_faq');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          String text = data["app_faq"];
          return formatWebText(text: text);
        }
      }
    }
    return '';
  }

  Future<String> getPrivacyPolicy() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'app_privacy_policy');
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          String text = data["app_privacy_policy"];
          return formatWebText(text: text);
        }
      }
    }
    return '';
  }

  Future<String> checkOtp() async {
    BaseModel req = BaseModel(methodName: 'otp_status');
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    final response = await postRequest(body: req.toJson());
    customProgressDialog.dismiss();
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        return "${data['otp_status']}";
      }
    }
    return '';
  }

  Future<String> getProfile() async {
    ReqWithUserId req = ReqWithUserId(methodName: "user_profile");
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (_handleStatus(jsonData)) {
        final data = jsonData[AppConstants.tag];
        String success = "${data['success']}";
        if (success == "1") {
          Preferences.setName(name: data["name"]);
          Preferences.setEmail(email: data["email"]);
          Preferences.setPhone(phoneNO: data["phone"]);
          Preferences.setUserImage(userImage: data["user_image"]);
          String stripeJson = data["stripe"];
          if (stripeJson != '') {
            Map<String, dynamic> stripeObject = jsonDecode(stripeJson);
            if (stripeObject["status"] == "active") {
              Config.stripeRenewDate = stripeObject["current_period_end"];
              Config.stripeStatus = "active";
              return "Premium";
            }
          }
        }
      }
    }
    return "Free";
  }

  Future<String> cancelStripeSubscription() async {
    ReqWithUserId req = ReqWithUserId(methodName: "cancel_stripe_subscription");
    final response = await postRequest(body: req.toJson());
    if (response.statusCode == 200) {
      Config.stripeStatus = "";
      Config.stripeJson = "";
      Config.stripeRenewDate = "";
      Config.vipSubscription = false;
      Config.allSubscription = false;
      IAPProvider.read(context).updateProStatus();
      return "success";
    }
    return "fail";
  }
}
