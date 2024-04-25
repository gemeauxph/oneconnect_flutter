part of '../fragment/withdrawal_history_fragment.dart';

mixin _WithdrawalHistoryMixin on State<WithdrawalHistoryFragment> {
  List<UserRedeem> userRedeemLists = [];
  bool noData = false;

  @override
  void initState() {
    super.initState();
    callData();
  }

  void callData() async {
    bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      if (Preferences.isLogin()) {
        history();
      }
    } else {
      showToast("no_internet_msg".tr());
    }
  }

  Future<void> history() async {
    ReqWithUserId req = ReqWithUserId(methodName: 'user_redeem_history');
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
          final data = jsonData[AppConstants.tag];
          for (var i = 0; i < data.length; i++) {
            final object = data[i];
            final redeemId = object['redeem_id'];
            final userPoints = object['user_points'];
            final redeemPrice = object['redeem_price'];
            final requestDate = object['request_date'];
            final status = object['status'];

            userRedeemLists.add(UserRedeem(
                redeemId: redeemId,
                userPoints: userPoints,
                redeemPrice: redeemPrice,
                requestDate: requestDate,
                status: status));
          }
          if (userRedeemLists.isEmpty) {
            noData = true;
          }
          setState(() {});
        }
      }
    } catch (error) {
      print("Error updateUIWithData  $error");
    }
  }
}
