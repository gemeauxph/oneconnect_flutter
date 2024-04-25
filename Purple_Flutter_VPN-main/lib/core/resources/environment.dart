import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//TODO: Put your endpoint and vpn auth here
const String endpoint =
    "https://new-flutter.truetest.xyz/api/"; //Please see the pattern, it must end with /
const String trueendpoint = "https://newvpn.testerdev.xyz/includes/api.php?";
const String vpnUsername = "";
const String vpnPassword = "";
const bool certificateVerify = true; //Turn it on if you use certificate

const String appName = "Nd VPN";

///TODO: Default theme mode
ThemeMode themeMode = ThemeMode.system;
bool allowUserChangeTheme = true;

///TODO: Add your supported locales here
List<Locale> supportedLocales = const [
  Locale('en', 'US'), //English
  Locale('in', 'ID'), //Indonesia
];

//TODO: Show signal strength on server list
const bool showSignalStrength = true;

//TODO: Store server list in local storage and show it when offline (not recommended)
const bool cacheServerList = true;

//TODO: iOS setup
const String providerBundleIdentifier =
    "com.ndvpn.ios.app.VPNExtension"; //Before it was VpnExtensionIdentifier
const String groupIdentifier = "com.ndvpn.ios.app";
const String iosAppID = "1234567890";
const String localizationDescription = "Nd VPN - Fast & Secure VPN";

///TODO: Customize your adRequest here
AdRequest get adRequest => const AdRequest();

///TODO: Allow user to unlock pro server with reward ads
bool unlockProServerWithRewardAds = true;

///TODO: Keep unlock pro server while reward ads fail to load
///TODO: By activate this, user can unlock pro server even if reward ads fail to load
bool unlockProServerWithRewardAdsFail = false;

///TODO: Set your ad unit id here
const String interstitialAdUnitID = "ca-app-pub-3940256099942544/1033173712";
const String bannerAdUnitID = "ca-app-pub-3940256099942544/6300978111";
const String interstitialRewardAdUnitID =
    "ca-app-pub-3940256099942544/5354046379";
const String openAdUnitID = "ca-app-pub-3940256099942544/3419835294";

///TODO: Set your custom subscription identifier here
Map<String, Map<String, dynamic>> subscriptionIdentifier = {};
