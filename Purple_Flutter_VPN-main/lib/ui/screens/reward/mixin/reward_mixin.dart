part of '../reward_screen.dart';

mixin _RewardScreenMixin on State<RewardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool noData = false;
  String totalPoint = '0';
  String money = '';
  String minimumRedeemPoints = "0";

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        userData();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  Future<void> userData() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'reward_points');
    String methodBody = jsonEncode(req.toJson());
    CustomProgressDialog customProgressDialog =
        CustomProgressDialog(context, dismissable: false, onDismiss: () {});
    customProgressDialog.show();
    try {
      http.Response response = await http.post(
        Uri.parse(AppConstants.baseURL),
        body: {'data': base64Encode(utf8.encode(methodBody))},
      ).then((value) {
        customProgressDialog.dismiss();
        return value;
      });

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
          Map<String, dynamic> data = jsonData[AppConstants.tag];
          String success = "${data['success']}";
          if (success == "1") {
            totalPoint = data["total_point"];
            String redeemPoints = '${data["redeem_points"]}';
            String redeemMoney = '${data["redeem_money"]}';
            minimumRedeemPoints = '${data["minimum_redeem_points"]}';
            money = "$redeemPoints Point = $redeemMoney";
            setState(() {});
          }
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }

  Future<void> rewardPointClaim() async {
    int point = int.parse(minimumRedeemPoints);
    int compair = int.parse(totalPoint);
    if (compair >= point) {
      startScreen(context, RewardPointClaim(userPoints: totalPoint));
    } else {
      showToast(
        "Minimum $minimumRedeemPoints Reward point is required to claim",
      );
    }
  }
}
