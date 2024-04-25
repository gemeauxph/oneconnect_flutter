import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class AppConstants {
  static const String stripeUrl = "https://api.stripe.com/v1/payment_intents";
  // static const String stripeSecretKey =
  //     "sk_test_51L6hZUBoqQ6Z2AxwD8EzIYyW5z7i5OFIa76Rv1IpzZ4yoEjZNlVIo4WpiMzVoPmEl5vvbNBD3ipVxVxqUuoM9P4X002BcC7b8s";
  static const String url = "https://newvpn.testerdev.xyz/";
  static const String baseURL = "https://newvpn.testerdev.xyz/api.php";
  static const String apiUrl = "https://newvpn.testerdev.xyz/includes/api.php";
  // ignore: constant_identifier_names
  static const LOGIN_TYPE_GOOGLE = 'google';
  // ignore: constant_identifier_names
  static const USER_NOT_CREATED = "User not created";
  static const tag = "ANDROID_REWARDS_APP";
  static const status = "status";
  static const int serviceConnectionTimeOut = 60;

  static String apiKey = 'dev';
  static int randomSalt = getRandomSalt();
  static String sign = mD5(apiKey + randomSalt.toString());
  static String packageName = 'com.luxullyvpn.vpnapp';

  static bool isOneConnect = false;
  static String oneConnectKey = '';
  static String oneConnectKey2 = '';

  static int getRandomSalt() {
    Random random = Random();
    return random.nextInt(900);
  }

  static String mD5(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return digest.toString();
  }
}
