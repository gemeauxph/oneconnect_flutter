import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import 'package:ndvpn/core/models/api_req/get_req_with_userid.dart';
import 'package:ndvpn/core/models/api_req/save_spinner_points_req.dart';
import 'package:ndvpn/core/providers/globals/ads_provider.dart';
import 'package:ndvpn/core/resources/environment.dart';
import 'package:ndvpn/core/utils/constant.dart';
import 'package:ndvpn/core/utils/utils.dart';
import 'package:ndvpn/ui/screens/login_screen/login_screen.dart';
import 'package:ndvpn/ui/screens/spin_wheel/controller/lucky_wheel_controller.dart';
import 'package:ndvpn/ui/screens/spin_wheel/spinner.dart';

class SpinningWheelPage extends StatefulWidget {
  const SpinningWheelPage({super.key});

  @override
  SpinningWheelPageState createState() => SpinningWheelPageState();
}

class SpinningWheelPageState extends State<SpinningWheelPage> {
  String prefprofileId = 'pref_profileId';
  List<LuckyItem> spinnerLists = [];
  String dailySpinnerLimit = '';
  String remainSpin = '';
  String adOnSpin = "false";
  bool isloading = true;
  LuckyWheelController mySpinController = LuckyWheelController();
  InterstitialAd? interstitialAd;
  Timer? interstitialTimeout;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      loadInterstitial();
    });
    spinnerLists.clear();
    init();
    super.initState();
  }

  @override
  void dispose() {
    interstitialTimeout?.cancel();
    super.dispose();
  }

  callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        init();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  void init() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'get_spinner');
    String methodBody = jsonEncode(req.toJson());

    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey("status")) {
          String status = jsonData["status"];
          String message = jsonData["message"];

          if (status == "-2") {
            replaceScreen(context, const LoginScreen());
            showToast(message);
          } else {
            showToast(message);
          }
        } else {
          dailySpinnerLimit = jsonData["daily_spinner_limit"];
          remainSpin = jsonData["remain_spin"];
          adOnSpin = jsonData["ad_on_spin"];
          updateUIWithData(jsonData);
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  void updateUIWithData(Map<String, dynamic> jsonData) {
    try {
      for (var item in jsonData[AppConstants.tag]) {
        LuckyItem objItem = LuckyItem(
            topText: item["points"],
            icon: Icons.monetization_on,
            color: HexColor(item["bg_color"]));
        spinnerLists.add(objItem);
      }

      if (spinnerLists.isNotEmpty) {
        isloading = false;
        setState(() {});
      }
    } catch (e) {
      print("Error updateUIWithData  $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lucky_wheel',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600))
            .tr(),
      ),
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xff0C1B3A),
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_spinner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spinner(
                    mySpinController: mySpinController,
                    wheelSize: MediaQuery.of(context).size.width * 0.8,
                    itemList: spinnerLists.map((luckyItem) {
                      return SpinItem(
                          label: luckyItem.topText,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          color: luckyItem.color);
                    }).toList(),
                    onFinished: (p0) {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('total_spins',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w400))
                            .tr(),
                        Text(dailySpinnerLimit,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('remaining_spins',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w400))
                            .tr(),
                        Text(remainSpin,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                      visible: remainSpin != "0",
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          onPressed: () async {
                            if (adOnSpin == "true") {
                              _itemClick();
                            } else {
                              showReward();
                            }
                          },
                          child: const Text('spin_now').tr())),
                ],
              ),
            ),
    );
  }

  void startLuckyRound() async {
    int rdm = Random().nextInt(6);
    mySpinController.itemList = spinnerLists.map((luckyItem) {
      return SpinItem(
          label: luckyItem.topText,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          color: luckyItem.color);
    }).toList();
    String winitem = mySpinController.itemList[rdm].label;
    sendSpinnerData(winitem);
    await mySpinController.spinNow(
        luckyIndex: rdm + 1, totalSpin: 10, baseSpinDuration: 20);
  }

  void _itemClick() async {
    return NAlertDialog(
      blur: 10,
      title: const Text("watch_ad_title").tr(),
      content: const Text("watch_ad_msg_2").tr(),
      actions: [
        TextButton(
          child: Text("watch_ad".tr()),
          onPressed: () {
            Navigator.pop(context);
            showReward();
          },
        ),
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Navigator.pop(context);
            startLuckyRound();
            Future.delayed(const Duration(seconds: 5), () async {
              interstitialAd?.showIfNotPro(context);
            });
          },
        ),
      ],
    ).show(context);
  }

  void showReward() async {
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});

    customProgressDialog.show();

    AdsProvider.read(context)
        .loadRewardAd(interstitialRewardAdUnitID)
        .then((value) async {
      customProgressDialog.dismiss();
      startLuckyRound();
      Future.delayed(const Duration(seconds: 5), () async {
        if (value != null) {
          value.show(onUserEarnedReward: (ad, reward) {});
        } else {
          if (unlockProServerWithRewardAdsFail) {
            await NAlertDialog(
              blur: 10,
              title: Text("no_reward_title".tr()),
              content: Text("no_reward_but_unlock_description".tr()),
              actions: [
                TextButton(
                    child: Text("understand".tr()),
                    onPressed: () => Navigator.pop(context))
              ],
            ).show(context);
          } else {
            NAlertDialog(
              blur: 10,
              title: Text("no_reward_title".tr()),
              content: Text("no_reward_description".tr()),
              actions: [
                TextButton(
                    child: Text("understand".tr()),
                    onPressed: () => Navigator.pop(context))
              ],
            ).show(context);
          }
        }
      });
    });
  }

  void loadInterstitial() {
    interstitialTimeout?.cancel();
    AdsProvider.read(context)
        .loadInterstitial(interstitialAdUnitID)
        .then((value) {
      if (value != null) {
        interstitialAd = value;
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            interstitialAd!.dispose();
            interstitialAd = null;
            loadInterstitial();
          },
        );
      } else {
        interstitialTimeout =
            Timer(const Duration(minutes: 1), loadInterstitial);
      }
    });
  }

  Future<void> sendSpinnerData(String point) async {
    try {
      SaveSpinnerPointsReq req = SaveSpinnerPointsReq(
          methodName: "save_spinner_points", points: point);
      String methodBody = jsonEncode(req.toJson());

      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('status')) {
          String status = jsonResponse['status'];
          String message = jsonResponse['message'];

          if (status == "-2") {
            replaceScreen(context, const LoginScreen());
            showToast(message);
          } else {
            showToast(message);
          }
        } else {
          final List<dynamic> jsonArray = jsonResponse[AppConstants.tag];

          for (int i = 0; i < jsonArray.length; i++) {
            final Map<String, dynamic> object = jsonArray[i];

            String msg = object['msg'];
            dailySpinnerLimit = object['daily_spinner_limit'];
            remainSpin = object['remain_spin'];

            Future.delayed(const Duration(seconds: 3), () {
              showToast("Congratulations, you have won $msg Point!");
              setState(() {});
            });
          }
        }
      } else {
        showToast('error'.tr());
      }
    } catch (e) {
      showToast('error'.tr());
    }
  }
}

class LuckyItem {
  String topText;
  IconData icon;
  Color color;

  LuckyItem({required this.topText, required this.icon, required this.color});
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
