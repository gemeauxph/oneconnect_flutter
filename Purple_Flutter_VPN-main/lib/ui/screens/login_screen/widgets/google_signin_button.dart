import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/main.dart';
import 'package:ndvpn/ui/screens/enter_reference_code/enter_reference_code_screen.dart';
import 'package:ndvpn/ui/screens/main_screen.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  GoogleSignInButtonState createState() => GoogleSignInButtonState();
}

class GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;
  String deviceid = Preferences.getDeviceId();
  final GoogleSignIn google = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).cardColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                googleSignIn();
                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 10, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.g_mobiledata),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'google_login',
                        style: Theme.of(context).textTheme.labelLarge,
                      ).tr(),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> googleSignIn() async {
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      await authService.signInWithGoogle(context).then((value) async {
        registerSocialNetwork(
            "${value!.userData!.id}",
            value.userData!.username!,
            value.userData!.email!,
            'google',
            customProgressDialog);
      }).catchError((e) {
        print("CHECKLOGIN ${e.toString()}");
      });
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  void registerSocialNetwork(String id, String sendName, String sendEmail,
      String type, CustomProgressDialog dialog) async {

    print("CHECKLOGIN $sendEmail");

    String deviceId = Preferences.getDeviceId();
    String methodBody = jsonEncode({
      'sign': AppConstants.sign,
      'salt': AppConstants.randomSalt.toString(),
      'package_name': AppConstants.packageName,
      'method_name': 'user_register',
      'type': type,
      'auth_id': id,
      'name': sendName,
      'email': sendEmail,
      'player_id': "123",
      'device_id': deviceId
    });

    print("CHECKGOOGLE ${AppConstants.sign} ${AppConstants.randomSalt.toString()} ${AppConstants.packageName} $id $sendName $sendEmail $deviceId");

    http.Response response = await http.post(
      Uri.parse(AppConstants.baseURL),
      body: {'data': base64Encode(utf8.encode(methodBody))},
    ).then((value) {
      dialog.dismiss();
      return value;
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);

      print("CHECKLOGIN ${response.body}");

      if (jsonMap.containsKey('status')) {
        String message = jsonMap['message'];
        showToast(message);
      } else {

        final data = jsonMap[AppConstants.tag];

        String msg = data['msg'];
        String success = "${data['success']}";

        if (success == '1') {
          final userId = "${data["user_id"]}";
          String email = data["email"];
          String name = data["name"];
          String referralCode = "${data["referral_code"]}";
          String stripeJson = data["stripe"];

          if (stripeJson != "") {
            Map<String, dynamic> stripeObject = jsonDecode(stripeJson);
            Config.stripeJson = data["stripe"];

            if (stripeObject["status"] == "active") {
              Config.stripeRenewDate = stripeObject["current_period_end"].toString();
              Config.vipSubscription = true;
              Config.allSubscription = true;
              Config.stripeStatus = "active";
            }
          }

          Preferences.setEmail(email: email);
          Preferences.setName(name: name);
          Preferences.setLogin(isLogin: true);
          Preferences.setProfileId(profileId: userId);
          Preferences.setLoginType(loginType: type);

          if (Config.loginBack) {
          } else {
            if (referralCode == "true") {
              replaceScreen(context, const EnterReferenceCodeScreen());
            } else {

              if (data['no_ads'] != null) {
                final noAds = (data['no_ads'] == 0) ? data['no_ads'] : int.parse(data['no_ads']);
                final premiumServers = (data['premium_servers'] == 0) ? data['premium_servers'] : int.parse(data['premium_servers']);
                final isPremium = data['is_premium'];
                final perks = data['perks'];
                final exp = data['exp'];

                Config.noAds = noAds == 1;
                Config.premiumServersAccess = premiumServers == 1;
                Config.isPremium = isPremium == "1";
                Config.perks = perks;
                Config.expiration = exp;
              }

              IAPProvider.read(context).updateProStatus();
              replaceScreen(context, const MainScreen());
            }
          }
        } else {
          if (data["is_suspended"] != null && data["is_suspended"] == "true") {
            if (type == "google") {
              await google.signOut();
            } else {}
          }
          Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
        }
      }
    }
  }
}
