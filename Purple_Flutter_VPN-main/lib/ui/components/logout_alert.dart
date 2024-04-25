import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/resources/colors.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'custom_card.dart';
import 'custom_divider.dart';
import 'package:http/http.dart' as http;

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'logout_message',
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge,
            ).tr(),
            const ColumnDivider(space: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () => closeScreen(context),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("cancel").tr(),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () => logout(context),
                    style: TextButton.styleFrom(
                      foregroundColor: warningColor,
                      backgroundColor: warningColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("logout").tr(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void logout(BuildContext context) async {
    ReqWithUserId req = ReqWithUserId(methodName: "logout");
    String methodBody = jsonEncode(req.toJson());
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Config.stripeStatus = "";
        Config.stripeJson = "";
        Config.stripeRenewDate = "";
        Preferences.setLogin(isLogin: false);
        Preferences.setProfileId(profileId: "");
        Preferences.setName(name: "");
        Preferences.setEmail(email: "");

        if (Preferences.getLoginType() == "google") {
          final GoogleSignIn google = GoogleSignIn();
          await google
              .signOut()
              .then((value) => startScreen(context, const LoginScreen()));
        } else {
          Preferences.setLogin(isLogin: false);
          startScreen(context, const LoginScreen());
        }
        Preferences.setProfileId(profileId: '');
      }
    } catch (e) {}
  }
}
