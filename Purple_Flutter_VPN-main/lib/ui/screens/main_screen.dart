import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/https/servers_http.dart';
import 'package:ndvpn/core/models/api_res/app_settings.dart';
import 'package:ndvpn/core/providers/globals/ads_provider.dart';
import 'package:ndvpn/core/providers/globals/iap_provider.dart';
import 'package:ndvpn/core/providers/globals/vpn_provider.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/config.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/components/custom_divider.dart';
import 'package:ndvpn/ui/components/logout_alert.dart';
import 'package:ndvpn/ui/components/redeem_dialog.dart';
import 'package:ndvpn/ui/screens/about_us_screen.dart';
import 'package:ndvpn/ui/screens/contact_us/contact_us_screen.dart';
import 'package:ndvpn/ui/screens/earn_point_screen.dart';
import 'package:ndvpn/ui/screens/faq_screen.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/privacy_policy_screen.dart';
import 'package:ndvpn/ui/screens/profile_screen.dart';
import 'package:ndvpn/ui/screens/redeem/redeem_screen.dart';
import 'package:ndvpn/ui/screens/reference_code_screen.dart';
import 'package:ndvpn/ui/screens/reward/reward_screen.dart';
import 'package:ndvpn/ui/screens/server_list_screen.dart';
import 'package:ndvpn/ui/screens/setting_screen.dart';
import 'package:ndvpn/ui/screens/spin_wheel/lucky_wheel_screen.dart';
import 'package:ndvpn/ui/screens/subscription_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/providers/globals/theme_provider.dart';
import '../components/connection_button.dart';
import '../components/custom_image.dart';
import 'connection_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      AppSettings? appSettings = await ServersHttp(context).getAppSettings();
      if (appSettings != null) {
        final String version = (await PackageInfo.fromPlatform()).version;
        if (appSettings.appUpdateStatus == "true" &&
            appSettings.appVersion != version) {
          showUpdateDialog(
              desc: appSettings.appUpdateDesc,
              url: appSettings.appRedirectUrl,
              status: appSettings.cancelUpdateStatus,
              context: context);
        }
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          backgroundColor: Theme.of(context).colorScheme.background,
          child: ListView(children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/icons/logo_android.png',
                      width: 75, height: 75),
                  ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('home').tr(),
                      onTap: () {
                        menuClick();
                        startScreen(context, const MainScreen());
                      }),
                  ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('profile').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const ProfileScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.emoji_events),
                      title: const Text('reward').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const RewardScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.link),
                      title: const Text('reference_code').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const ReferenceCodeScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.casino),
                      title: const Text('lucky_wheel').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const SpinningWheelPage());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.card_giftcard),
                      title: const Text('redeem').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const RedeemScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('language').tr(),
                      onTap: () =>
                          ThemeProvider.read(context).changeLanguage(context)),
                  ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('settings').tr(),
                      onTap: () {
                        menuClick();
                        startScreen(context, const SettingScreen());
                      }),
                  ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text("Login or Logout").tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          logout();
                        } else {
                          startScreen(context, const LoginScreen());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.mail),
                      title: const Text('contact_us').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const ContactUsScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('faq').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const FaqScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.score),
                      title: const Text('earn_point').tr(),
                      onTap: () {
                        menuClick();
                        if (Preferences.isLogin()) {
                          startScreen(context, const EarnPointScreen());
                        } else {
                          showToast("no_login_msg".tr());
                        }
                      }),
                  ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('share_app').tr(),
                      onTap: () {
                        menuClick();
                        shareApp();
                      }),
                  ListTile(
                      leading: const Icon(Icons.thumb_up),
                      title: const Text('rate_app').tr(),
                      onTap: () {
                        menuClick();
                        rateUs();
                      }),
                  ListTile(
                      leading: const Icon(Icons.apps),
                      title: const Text('more_app').tr(),
                      onTap: () {
                        menuClick();
                        rateUs();
                      }),
                  ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('check_update').tr(),
                      onTap: () => _checkUpdate()),
                  ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('privacy_policy').tr(),
                      onTap: () {
                        menuClick();
                        startScreen(context, const PrivacyPolicyScreen());
                      }),
                  ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('about').tr(),
                      onTap: () {
                        menuClick();
                        startScreen(context, const AboutUsScreen());
                      }),
                ],
              ),
            ),
          ])),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              _appbarWidget(context),
              _connectionInfoWidget(context),
              const Center(child: ConnectionButton()),
              const ColumnDivider(),
              context.watch<IAPProvider>().isPro || Config.appleOn == "1"
                  ? const SizedBox.shrink()
                  : _premiumWidget(context),
              Center(
                  child: context.watch<IAPProvider>().isPro
                      ? const SizedBox.shrink()
                      : const ColumnDivider(space: 20)),
              _selectVpnWidget(context),
              const ColumnDivider(space: 20),
              Center(
                  child: context.watch<IAPProvider>().isPro
                      ? const SizedBox.shrink()
                      : AdsProvider.bannerAd(bannerAdUnitID,
                          adsize: AdSize.mediumRectangle)),
              const ColumnDivider(space: 20),
            ],
          ),
        ],
      ),
    );
  }

  ///Select VPN button, Change the code below if you want to customize the button
  Widget _selectVpnWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("select_vpn_server".tr(),
              style: const TextStyle(color: Colors.white)),
          const ColumnDivider(space: 5),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _selectVpnClick(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  var config = vpnProvider.vpnConfig;
                  return Row(
                    children: [
                      if (config != null)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: config.flagUrl.contains("http")
                              ? CustomImage(
                                  url: config.flagUrl,
                                  fit: BoxFit.contain,
                                  borderRadius: BorderRadius.circular(5),
                                )
                              : Image.asset(
                                  "icons/flags/png/${config.flagUrl}.png",
                                  package: "country_icons"),
                        ),
                      if (config == null)
                        const SizedBox(
                            width: 32, height: 32, child: Icon(Icons.language)),
                      const SizedBox(width: 10),
                      Text(config?.serverName ?? 'select_server'.tr()),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                      const SizedBox(width: 10),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///Connection info widget, Change the code below if you want to customize the widget
  Widget _connectionInfoWidget(BuildContext context) {
    return CupertinoButton(
      onPressed: () => startScreen(context, const ConnectionDetailScreen()),
      child: SizedBox(
        height: 100,
        child: Consumer<VpnProvider>(builder: (context, value, child) {
          double bytein = 0;
          double byteout = 0;
          if ((value.vpnStatus?.byteIn?.trim().isEmpty ?? false) ||
              value.vpnStatus?.byteIn == "0") {
            bytein = 0;
          } else {
            bytein = double.tryParse(value.vpnStatus!.byteIn.toString()) ?? 0;
          }

          if ((value.vpnStatus?.byteOut?.trim().isEmpty ?? false) ||
              value.vpnStatus?.byteIn == "0") {
            byteout = 0;
          } else {
            byteout = double.tryParse(value.vpnStatus!.byteOut.toString()) ?? 0;
          }

          return Row(
            children: [
              Expanded(
                child: Card(
                  color: const Color(0xFF2A3875),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'download',
                        style: TextStyle(
                          fontSize: 14,
                          // color: Colors.white,
                          fontFamily: 'campton_bold',
                        ),
                      ).tr(),
                      Text(
                        "${formatBytes(bytein.floor(), 0)}/s",
                        style: const TextStyle(
                          fontSize: 24,
                          // color: Colors.white,
                          fontFamily: 'campton_bold',
                        ),
                      ),
                      const Text(
                        'Status',
                        style: TextStyle(
                            // color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  color: const Color(0xFF2A3875),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'upload',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'campton_bold',
                        ),
                      ).tr(),
                      Text(
                        "${formatBytes(byteout.floor(), 0)}/s",
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'campton_bold',
                        ),
                      ),
                      const Text(
                        'status',
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _premiumWidget(BuildContext context) {
    return GestureDetector(
        onTap: () => _upgradeProClick(context),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: double.infinity,
          height: 120.0,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width -
                    MediaQuery.of(context).size.width / 8,
                height: 90.0,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/primier_design.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10.0),
                    Container(
                      width: 60.0,
                      height: 60.0,
                      margin: const EdgeInsets.only(left: 15.0),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/icon_crown.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Center(
                      child: const Text(
                        'unlock_msg',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  logout() {
    const DialogBackground(
      dialog: LogoutScreen(),
      blur: 10,
      dismissable: false,
    ).show(context);
  }

  ///Appbar, Change the code below if you want to customize the appbar
  Widget _appbarWidget(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 0,
              top: 5,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                height: 45,
                width: 150,
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
                left: 5,
                top: 5,
                child: IconButton(
                    onPressed: () {
                      menuClick();
                    },
                    icon: const Icon(Icons.menu))),
            // Positioned(
            //   right: 0,
            //   child: IconButton(
            //     padding: EdgeInsets.zero,
            //     onPressed: () => _upgradeProClick(context),
            //     icon: LottieBuilder.asset("assets/animations/crown_free.json"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  ///Open the subscription screen when user click on the crown icon
  void _upgradeProClick(BuildContext context) {
    startScreen(context, SubscriptionScreen());
  }

  void profileUpdate(BuildContext context) {
    startScreen(context, const ProfileScreen());
  }

  ///Open the menu when user click on the menu icon
  void menuClick() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  ///Open the server list screen when user click on the select server button
  void _selectVpnClick(BuildContext context) {
    startScreen(context, const ServerListScreen());
  }

  ///Check for update when user click on the update button
  void _checkUpdate() async {
    if (Platform.isAndroid) {
      checkUpdate(context).then((value) {
        if (!value) {
          NAlertDialog(
            title: const Text("update_not_available").tr(),
            content: const Text("update_not_available_content").tr(),
            blur: 10,
            actions: [
              TextButton(
                  onPressed: () => closeScreen(context),
                  child: const Text("close").tr())
            ],
          ).show(context);
        }
      });
    } else {
      launchUrlString("https://apps.apple.com/app/id$iosAppID");
    }
  }

  Future<void> shareApp() async {
    try {
      String packageName = (await PackageInfo.fromPlatform()).packageName;
      String message =
          "\n I recommend you this app \n\n${Platform.isAndroid ? "https://play.google.com/store/apps/details?id=$packageName" : "https://apps.apple.com/app/idYOUR_APP_ID"}";

      if (Platform.isAndroid) {
        await Share.share(
          message,
          subject: appName,
        );
      } else if (Platform.isIOS) {
        launchUrlString("https://apps.apple.com/app/id$iosAppID");
      }
    } catch (e) {
      // Handle exceptions as needed
    }
  }

  Future<void> rateUs() async {
    final String packageName = (await PackageInfo.fromPlatform()).packageName;

    final Uri uri = Platform.isAndroid
        ? Uri.parse('market://details?id=$packageName')
        : Uri.parse('https://apps.apple.com/app/$iosAppID');

    try {
      await launchUrl(
        uri,
      );
    } catch (e) {
      if (Platform.isAndroid) {
        await launch(
            'https://play.google.com/store/apps/details?id=$packageName');
      } else if (Platform.isIOS) {
        launchUrlString("https://apps.apple.com/app/id$iosAppID");
      }
    }
  }
}
